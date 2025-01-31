class NodeAT12 < Formula
  desc "Platform built on V8 to build network applications"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v12.17.0/node-v12.17.0.tar.xz"
  sha256 "ca6d9e86a7fffc95f0ac6424ae242ed03026ed1f15a96ed5ac5ae3603f6f4e33"
  revision 1

  bottle do
    cellar :any
    sha256 "4741859ca7b8e2fa8e463e160bd33f24353388e4aabbab0d321abb9c55d40055" => :catalina
    sha256 "df40b3595dc9792b4e749d62db75da306a45016eea79c165e6963aa056938301" => :mojave
    sha256 "31f99cfcd8862c35f90071e6f04694d98a2dd7195b0a89e294c9da36684e7a22" => :high_sierra
    sha256 "ab3e1117f983523d76ada07b053184989f779f1d4f81d0508af97faeab4a49e2" => :x86_64_linux
  end

  keg_only :versioned_formula

  depends_on "pkg-config" => :build
  depends_on "python@3.8" => :build
  depends_on "icu4c"

  def install
    # make sure subprocesses spawned by make are using our Python 3
    ENV["PYTHON"] = Formula["python@3.8"].opt_bin/"python3"

    system "python3", "configure.py", "--prefix=#{prefix}", "--with-intl=system-icu"
    system "make", "install"
  end

  def post_install
    (lib/"node_modules/npm/npmrc").atomic_write("prefix = #{HOMEBREW_PREFIX}\n")
  end

  test do
    path = testpath/"test.js"
    path.write "console.log('hello');"

    output = shell_output("#{bin}/node #{path}").strip
    assert_equal "hello", output
    output = shell_output("#{bin}/node -e 'console.log(new Intl.NumberFormat(\"en-EN\").format(1234.56))'").strip
    assert_equal "1,234.56", output

    output = shell_output("#{bin}/node -e 'console.log(new Intl.NumberFormat(\"de-DE\").format(1234.56))'").strip
    assert_equal "1.234,56", output

    # make sure npm can find node
    ENV.prepend_path "PATH", opt_bin
    ENV.delete "NVM_NODEJS_ORG_MIRROR"
    assert_equal which("node"), opt_bin/"node"
    assert_predicate bin/"npm", :exist?, "npm must exist"
    assert_predicate bin/"npm", :executable?, "npm must be executable"
    npm_args = ["-ddd", "--cache=#{HOMEBREW_CACHE}/npm_cache", "--build-from-source"]
    system "#{bin}/npm", *npm_args, "install", ("--unsafe-perm" if Process.uid.zero?), "npm@latest"
    unless head?
      system "#{bin}/npm", *npm_args, "install", ("--unsafe-perm" if Process.uid.zero?), "bufferutil"
    end
    assert_predicate bin/"npx", :exist?, "npx must exist"
    assert_predicate bin/"npx", :executable?, "npx must be executable"
    assert_match "< hello >", shell_output("#{bin}/npx cowsay hello")
  end
end
