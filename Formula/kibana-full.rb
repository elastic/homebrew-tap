class KibanaFull < Formula
  desc "Analytics and search dashboard for Elasticsearch"
  homepage "https://www.elastic.co/products/kibana"
  url "https://artifacts.elastic.co/downloads/kibana/kibana-7.3.0-darwin-x86_64.tar.gz?tap=elastic/homebrew-tap"
  version "7.3.0"
  sha256 "c9beedad7fed18de08ce09771732a53e01fd7064e60859c3a09c023f65a5e6df"
  conflicts_with "kibana"
  conflicts_with "kibana-oss"

  def install
    prefix.install(
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

    cd prefix do
      packaged_config = IO.read "config/kibana.yml"
      IO.write "config/kibana.yml", "path.data: #{var}/lib/kibana/data\n" + packaged_config
      (etc/"kibana").install Dir["config/*"]
      rm_rf "config"
      rm_rf "data"
    end
  end

  def post_install
    ln_s etc/"kibana", prefix/"config"
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
