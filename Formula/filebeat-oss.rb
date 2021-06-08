class FilebeatOss < Formula
  desc "File harvester to ship log files to Elasticsearch or Logstash"
  homepage "https://www.elastic.co/products/beats/filebeat"
  url "https://snapshots.elastic.co/7.13.2-a3fd10d8/downloads/beats/filebeat/filebeat-oss-7.13.2-SNAPSHOT-darwin-x86_64.tar.gz?tap=elastic/homebrew-tap"
  version "7.13.2-SNAPSHOT"
  sha256 "d302a9f1eaaaf31e5f65ed6f9c37af89c52a4e9aa7d6f8fdb1a570ee9b159dd4"
  conflicts_with "filebeat"
  conflicts_with "filebeat-full"

  bottle :unneeded

  def install
    ["fields.yml", "ingest", "kibana", "module"].each { |d| libexec.install d if File.exist?(d) }
    (libexec/"bin").install "filebeat"
    (etc/"filebeat").install "filebeat.yml"
    (etc/"filebeat").install "modules.d" if File.exist?("modules.d")

    (bin/"filebeat").write <<~EOS
      #!/bin/sh
      exec #{libexec}/bin/filebeat \
        --path.config #{etc}/filebeat \
        --path.data #{var}/lib/filebeat \
        --path.home #{libexec} \
        --path.logs #{var}/log/filebeat \
        "$@"
    EOS
  end

  plist_options :manual => "filebeat"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>Program</key>
        <string>#{opt_bin}/filebeat</string>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
  EOS
  end

  test do
    log_file = testpath/"test.log"
    touch log_file

    (testpath/"filebeat.yml").write <<~EOS
      filebeat:
        inputs:
          -
            paths:
              - #{log_file}
            scan_frequency: 0.1s
      output:
        file:
          path: #{testpath}
    EOS

    (testpath/"log").mkpath
    (testpath/"data").mkpath

    filebeat_pid = fork do
      exec bin/"filebeat", "-c", testpath/"filebeat.yml", "-path.config",
                           testpath/"filebeat", "-path.home=#{testpath}",
                           "-path.logs", testpath/"log", "-path.data", testpath
    end
    begin
      sleep 1
      log_file.append_lines "foo bar baz"
      sleep 5

      assert_predicate testpath/"filebeat", :exist?
    ensure
      Process.kill("TERM", filebeat_pid)
    end
  end
end
