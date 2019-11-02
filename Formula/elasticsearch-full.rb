class ElasticsearchFull < Formula
  desc "Distributed search & analytics engine"
  homepage "https://www.elastic.co/products/elasticsearch"
  url "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.4.2-darwin-x86_64.tar.gz?tap=elastic/homebrew-tap"
  version "7.4.2"
  sha256 "6d59a91a57c0d15cb302cf12ea835b40d0bcef05499fbc880247580b3f8720ed"
  conflicts_with "elasticsearch"
  conflicts_with "elasticsearch-oss"

  bottle :unneeded

  def cluster_name
    "elasticsearch_#{ENV["USER"]}"
  end

  def install
    # Install everything else into package directory
    libexec.install "bin", "config", "jdk.app", "lib", "modules"

    inreplace libexec/"bin/elasticsearch-env",
              "if [ -z \"$ES_PATH_CONF\" ]; then ES_PATH_CONF=\"$ES_HOME\"/config; fi",
              "if [ -z \"$ES_PATH_CONF\" ]; then ES_PATH_CONF=\"#{etc}/elasticsearch\"; fi"

    # Set up Elasticsearch for local development:
    inreplace "#{libexec}/config/elasticsearch.yml" do |s|
      # 1. Give the cluster a unique name
      s.gsub!(/#\s*cluster\.name\: .*/, "cluster.name: #{cluster_name}")

      # 2. Configure paths
      s.sub!(%r{#\s*path\.data: /path/to.+$}, "path.data: #{var}/lib/elasticsearch/")
      s.sub!(%r{#\s*path\.logs: /path/to.+$}, "path.logs: #{var}/log/elasticsearch/")
    end

    inreplace "#{libexec}/config/jvm.options", %r{logs/gc.log}, "#{var}/log/elasticsearch/gc.log"

    # Move config files into etc
    (etc/"elasticsearch").install Dir[libexec/"config/*"]
    (libexec/"config").rmtree

    Dir.foreach(libexec/"bin") do |f|
      next if f == "." || f == ".." || !File.extname(f).empty?

      bin.install libexec/"bin"/f
    end
    bin.env_script_all_files(libexec/"bin", {})

    system "codesign", "-f", "-s", "-", "#{libexec}/modules/x-pack-ml/platform/darwin-x86_64/controller.app", "--deep"
  end

  def post_install
    # Make sure runtime directories exist
    (var/"lib/elasticsearch/#{cluster_name}").mkpath
    (var/"log/elasticsearch").mkpath
    ln_s etc/"elasticsearch", libexec/"config"
    (var/"elasticsearch/plugins").mkpath
    ln_s var/"elasticsearch/plugins", libexec/"plugins"
  end

  def caveats
    s = <<~EOS
      Data:    #{var}/lib/elasticsearch/#{cluster_name}/
      Logs:    #{var}/log/elasticsearch/#{cluster_name}.log
      Plugins: #{var}/elasticsearch/plugins/
      Config:  #{etc}/elasticsearch/
    EOS

    s
  end

  plist_options :manual => "elasticsearch"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>KeepAlive</key>
          <false/>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{opt_bin}/elasticsearch</string>
          </array>
          <key>EnvironmentVariables</key>
          <dict>
          </dict>
          <key>RunAtLoad</key>
          <true/>
          <key>WorkingDirectory</key>
          <string>#{var}</string>
          <key>StandardErrorPath</key>
          <string>#{var}/log/elasticsearch.log</string>
          <key>StandardOutPath</key>
          <string>#{var}/log/elasticsearch.log</string>
        </dict>
      </plist>
    EOS
  end

  test do
    require "socket"

    server = TCPServer.new(0)
    port = server.addr[1]
    server.close

    mkdir testpath/"config"
    cp etc/"elasticsearch/jvm.options", testpath/"config"
    cp etc/"elasticsearch/log4j2.properties", testpath/"config"

    ENV["ES_PATH_CONF"] = testpath/"config"

    system "#{bin}/elasticsearch-plugin", "list"

    pid = testpath/"pid"
    begin
      system "#{bin}/elasticsearch", "-d", "-p", pid, "-Epath.data=#{testpath}/data", "-Epath.logs=#{testpath}/logs", "-Enode.name=test-cli", "-Ehttp.port=#{port}"
      sleep 15
      system "curl", "-XGET", "localhost:#{port}/"
      output = shell_output("curl -s -XGET localhost:#{port}/_cat/nodes")
      assert_match "test-cli", output
    ensure
      Process.kill(9, pid.read.to_i)
    end

    server = TCPServer.new(0)
    port = server.addr[1]
    server.close

    (testpath/"config/elasticsearch.yml").write <<~EOS
      path.data: #{testpath}/data
      path.logs: #{testpath}/logs
      node.name: test-es-path-conf
      http.port: #{port}
    EOS

    pid = testpath/"pid"
    begin
      system "#{bin}/elasticsearch", "-d", "-p", pid
      sleep 10
      system "curl", "-XGET", "localhost:#{port}/"
      output = shell_output("curl -s -XGET localhost:#{port}/_cat/nodes")
      assert_match "test-es-path-conf", output
    ensure
      Process.kill(9, pid.read.to_i)
    end
  end
end
