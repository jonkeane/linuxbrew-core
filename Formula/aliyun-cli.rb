class AliyunCli < Formula
  desc "Universal Command-Line Interface for Alibaba Cloud"
  homepage "https://github.com/aliyun/aliyun-cli"
  url "https://github.com/aliyun/aliyun-cli/archive/v3.0.45.tar.gz"
  sha256 "9e93dcdeb5696c1ee14209559ab799bc70ba6d15f53cb354e8b92f62fd37c8dd"

  bottle do
    cellar :any_skip_relocation
    sha256 "0ad473c5b1fea2bbfb629a7fc1bb7c1b94c6777a942d74ce13e71f01525da415" => :catalina
    sha256 "e8356f26b617a861e51edc7be8033da1568070095451563bf3258f4d0cc716f3" => :mojave
    sha256 "2665eeeeb7332b337d632e296eacf88f5df3bef622642ae0630a4b9bdcfdf5f5" => :high_sierra
    sha256 "41ade49a0d3cdf96ff25e4baf8367e90631576666dcfaeb5a771505292a4db9a" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GO111MODULE"] = "off"
    ENV["GOPATH"] = buildpath
    ENV["PATH"] = "#{ENV["PATH"]}:#{buildpath}/bin"
    (buildpath/"src/github.com/aliyun/aliyun-cli").install buildpath.children
    cd "src/github.com/aliyun/aliyun-cli" do
      system "make", "metas"
      system "go", "build", "-o", bin/"aliyun", "-ldflags",
                            "-X 'github.com/aliyun/aliyun-cli/cli.Version=#{version}'", "main/main.go"
      prefix.install_metafiles
    end
  end

  test do
    version_out = shell_output("#{bin}/aliyun version")
    assert_match version.to_s, version_out

    help_out = shell_output("#{bin}/aliyun --help")
    assert_match "Alibaba Cloud Command Line Interface Version #{version}", help_out
    assert_match "", help_out
    assert_match "Usage:", help_out
    assert_match "aliyun <product> <operation> [--parameter1 value1 --parameter2 value2 ...]", help_out

    oss_out = shell_output("#{bin}/aliyun oss")
    assert_match "Object Storage Service", oss_out
    assert_match "aliyun oss [command] [args...] [options...]", oss_out
  end
end
