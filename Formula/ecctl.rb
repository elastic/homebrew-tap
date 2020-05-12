# This file was generated by GoReleaser. DO NOT EDIT.
class Ecctl < Formula
  desc "Elastic Cloud Control, the official Elastic Cloud and ECE command line interface"
  homepage "https://github.com/elastic/ecctl"
  version "1.0.0-beta3"

  if OS.mac?
    url "https://download.elastic.co/downloads/ecctl/1.0.0-beta3/ecctl_1.0.0-beta3_darwin_amd64.tar.gz", :using => CurlDownloadStrategy
    sha256 "2c2a6d3c64d93f3ef7edb6d8dfa4ce279770faad20b6d9c31cb8a3319dbbc3ef"
  elsif OS.linux?
    url "https://download.elastic.co/downloads/ecctl/1.0.0-beta3/ecctl_1.0.0-beta3_linux_amd64.tar.gz", :using => CurlDownloadStrategy
    sha256 "5c05139a9fd61341efc9ff9e9b9623341fd8005f8581be8a74951ac8a296726a"
  end

  def install
    bin.install "ecctl"
    system "#{bin}/ecctl", "generate", "completions", "-l", "#{var}/ecctl.auto"
  end

  def caveats; <<~EOS
    To get autocompletions working make sure to run "source <(ecctl generate completions)".
    If you prefer to add to your shell interpreter configuration file run, for bash or zsh respectively:
    * `echo "source <(ecctl generate completions)" >> ~/.bash_profile`
    * `echo "source <(ecctl generate completions)" >> ~/.zshrc`.
  EOS
  end

  test do
    system "#{bin}/ecctl version"
  end
end
