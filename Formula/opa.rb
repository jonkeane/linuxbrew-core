class Opa < Formula
  desc "Open source, general-purpose policy engine"
  homepage "https://www.openpolicyagent.org"
  url "https://github.com/open-policy-agent/opa/archive/v0.20.4.tar.gz"
  sha256 "60821a77daa55e769c719b830c8f8715ddb9d4e6f1cd58ec80388086bb0b3b92"
  head "https://github.com/open-policy-agent/opa.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "416bb2cfc4e7248a2f718f407e56364c6f007ea39246667fad38ace6ee4a462d" => :catalina
    sha256 "4d36cc920f0e09fa13bba51b8add92df0f3d774915af06f703c7fbc0cec573df" => :mojave
    sha256 "5bdfb14651c15d302d716dd88086a9761fd5e0e0af36a1f34532b309200a1a64" => :high_sierra
    sha256 "ae6b49620585157d0981008ef3b50932dd79e46172c64c62f8c1d842de393a1b" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-o", bin/"opa", "-trimpath", "-ldflags",
                 "-X github.com/open-policy-agent/opa/version.Version=#{version}"
    system "./build/gen-man.sh", "man1"
    man.install "man1"
    prefix.install_metafiles
  end

  test do
    output = shell_output("#{bin}/opa eval -f pretty '[x, 2] = [1, y]' 2>&1")
    assert_equal "+---+---+\n| x | y |\n+---+---+\n| 1 | 2 |\n+---+---+\n", output
    assert_match "Version: #{version}", shell_output("#{bin}/opa version 2>&1")
  end
end
