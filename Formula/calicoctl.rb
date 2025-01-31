class Calicoctl < Formula
  desc "Calico CLI tool"
  homepage "https://www.projectcalico.org"
  url "https://github.com/projectcalico/calicoctl.git",
      :tag      => "v3.14.0",
      :revision => "c97876ba2dfa524c121af82f16e46b5167bd19f5"

  bottle do
    cellar :any_skip_relocation
    sha256 "0a4bede065a95f53668bd45f88446d2a30d87b6e4a2b72be04ceb27d8f54399b" => :catalina
    sha256 "a0b74a08c607a55cd3b1485bd55a4a6d5ef02a2ee3b1c8bd230c113ec6deb9c3" => :mojave
    sha256 "1e43d96c2fe04420119c51e504ca9659e963eecd7ae0b2770a0c82df622c9dd0" => :high_sierra
    sha256 "15d8f6a75034c153589f108e1996b82bb3b0c4b7eaf26d322956e94b86e0f1af" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath

    dir = buildpath/"src/github.com/projectcalico/calicoctl"
    dir.install buildpath.children

    cd dir do
      commands = "github.com/projectcalico/calicoctl/calicoctl/commands"
      system "go", "build", "-v", "-o", "dist/calicoctl-darwin-amd64",
                            "-ldflags", "-X #{commands}.VERSION=#{stable.specs[:tag]} " \
                                        "-X #{commands}.GIT_REVISION=#{stable.specs[:revision][0, 8]} " \
                                        "-s -w",
                            "calicoctl/calicoctl.go"
      bin.install "dist/calicoctl-darwin-amd64" => "calicoctl"
      prefix.install_metafiles
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/calicoctl version", 1)
  end
end
