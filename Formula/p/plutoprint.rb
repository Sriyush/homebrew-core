class Plutoprint < Formula
  include Language::Python::Virtualenv

  desc "Generate PDFs and Images from HTML"
  homepage "https://github.com/plutoprint/plutoprint"
  url "https://files.pythonhosted.org/packages/c0/35/aca0b163ae7a201b8b9c27f1c5bc5020b0badc93c7019020288f2099ca21/plutoprint-0.9.0.tar.gz"
  sha256 "05c3c425dd57dbd5db0c26449e17e9e8cbc4eb041320697fa7c3f042dd3c1960"
  license "MIT"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "plutobook"
  depends_on "python@3.13"

  on_macos do
    depends_on "llvm" if DevelopmentTools.clang_build_version <= 1499
  end

  on_ventura do
    depends_on "llvm"
  end

  on_linux do
    depends_on "patchelf" => :build
  end

  fails_with :clang do
    build 1499
    cause "Requires C++20 support"
  end

  fails_with :gcc do
    version "9"
    cause "requires GCC 10+"
  end

  def python3
    "python3.13"
  end

  resource "meson" do
    url "https://files.pythonhosted.org/packages/0a/8a/8315a2711dd269533019d7fdad1cf79416aadff454c539c2da88bc6e7200/meson-1.9.0.tar.gz"
    sha256 "cd27277649b5ed50d19875031de516e270b22e890d9db65ed9af57d18ebc498d"
  end

  resource "meson-python" do
    url "https://files.pythonhosted.org/packages/26/bd/fdb26366443620f1a8a4d4ec7bfa37d1fbbe7bf737b257c205bbcf95ba95/meson_python-0.18.0.tar.gz"
    sha256 "c56a99ec9df669a40662fe46960321af6e4b14106c14db228709c1628e23848d"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/a1/d4/1fc4078c65507b51b96ca8f8c3ba19e6a61c8253c72794544580a7b6c24d/packaging-25.0.tar.gz"
    sha256 "d443872c98d677bf60f6a1f2f8c1cb748e8fe762d2bf9d3148b5599295b0fc4f"
  end

  resource "pyproject-metadata" do
    url "https://files.pythonhosted.org/packages/64/ae/5fa065b049e97f96880de0611dbba513f0ee313b6edd0a64664c7b46a8e8/pyproject_metadata-0.9.1.tar.gz"
    sha256 "b8b2253dd1b7062b78cf949a115f02ba7fa4114aabe63fa10528e9e1a954a816"
  end

  def install
    if OS.mac? && (MacOS.version == :ventura || DevelopmentTools.clang_build_version <= 1499)
      ENV.llvm_clang
      llvm = Formula["llvm"]
      ENV.append "LDFLAGS", "-L#{llvm.opt_lib}/c++ -L#{llvm.opt_lib}/unwind -lunwind"
    end

    virtualenv_install_with_resources
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/plutoprint --version")

    (testpath/"test.html").write <<~HTML
      <h1>Hello World!</h1>
    HTML

    system bin/"plutoprint", "test.html", "test.pdf"
    assert_path_exists testpath/"test.pdf"
  end
end
