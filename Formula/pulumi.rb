class Pulumi < Formula
  desc "Cloud native development platform"
  homepage "https://pulumi.io/"
  url "https://github.com/pulumi/pulumi.git",
      :tag      => "v2.3.0",
      :revision => "aa5dfe4289bec3c48d1ec599bd0b747cfc3da33f"
  head "https://github.com/pulumi/pulumi.git"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "a64610f49b4b6a646deba8fbd74a764f8921a1b6c6e0bf7d0447aee33c83928c" => :catalina
    sha256 "7cb0c3f892021dc7938296f80ee4c926cdc9d759cdfd63efce4fe1212b1c4bfa" => :mojave
    sha256 "08e9c992112a3f527b0b2dde2d76465a8959af0a9d82886aa9b8c63168eeb8a3" => :high_sierra
    sha256 "921b999da034bfce4b92f7dbe966c1a704dbaf4448406a08d91348bc94122fc2" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "on"

    dir = buildpath/"src/github.com/pulumi/pulumi"
    dir.install buildpath.children

    cd dir do
      cd "./sdk" do
        system "go", "mod", "download"
      end
      cd "./pkg" do
        system "go", "mod", "download"
      end
      system "make", "brew"
      bin.install Dir["#{buildpath}/bin/*"]
      prefix.install_metafiles

      # Install bash completion
      output = Utils.popen_read("#{bin}/pulumi gen-completion bash")
      (bash_completion/"pulumi").write output

      # Install zsh completion
      output = Utils.popen_read("#{bin}/pulumi gen-completion zsh")
      (zsh_completion/"_pulumi").write output

      # Install fish completion
      output = Utils.popen_read("#{bin}/pulumi gen-completion fish")
      (fish_completion/"_pulumi").write output
    end
  end

  test do
    ENV["PULUMI_ACCESS_TOKEN"] = "local://"
    ENV["PULUMI_TEMPLATE_PATH"] = testpath/"templates"
    system "#{bin}/pulumi", "new", "aws-typescript", "--generate-only",
                                                     "--force", "-y"
    assert_predicate testpath/"Pulumi.yaml", :exist?, "Project was not created"
  end
end
