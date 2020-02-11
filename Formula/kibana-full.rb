class KibanaFull < Formula
  desc "Analytics and search dashboard for Elasticsearch"
  homepage "https://www.elastic.co/products/kibana"
  url "https://artifacts.elastic.co/downloads/kibana/kibana-7.6.0-darwin-x86_64.tar.gz?tap=elastic/homebrew-tap"
  version "7.6.0"
  sha256 "550dfea07dd7cf9edd57c97320cdbd0ac675b3f379d1c6af5a3a90a759f83ca2"
  conflicts_with "kibana"
  conflicts_with "kibana-oss"

  bottle :unneeded

  def install
    libexec.install(
      "bin",
      "built_assets",
      "config",
      "data",
      "node",
      "node_modules",
      "optimize",
      "package.json",
      "plugins",
      "src",
      "webpackShims",
      "x-pack",
    )

    Pathname.glob(libexec/"bin/*") do |f|
      next if f.directory?
      bin.install libexec/"bin"/f
    end
    bin.env_script_all_files(libexec/"bin", { "KIBANA_PATH_CONF" => etc/"kibana", "DATA_PATH" => var/"lib/kibana/data" })

    cd libexec do
      packaged_config = IO.read "config/kibana.yml"
      IO.write "config/kibana.yml", "path.data: #{var}/lib/kibana/data\n" + packaged_config
      (etc/"kibana").install Dir["config/*"]
      rm_rf "config"
      rm_rf "data"
    end
  end

  def post_install
    (var/"lib/kibana/data").mkpath
    (prefix/"plugins").mkdir
  end

  def caveats; <<~EOS
    Config: #{etc}/kibana/
    If you wish to preserve your plugins upon upgrade, make a copy of
    #{opt_prefix}/plugins before upgrading, and copy it into the
    new keg location after upgrading.
  EOS
  end

  plist_options :manual => "kibana"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>Program</key>
        <string>#{opt_bin}/kibana</string>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
  EOS
  end

  test do
    ENV["BABEL_CACHE_PATH"] = testpath/".babelcache.json"
    assert_match /#{version}/, shell_output("#{bin}/kibana -V")
  end
end
