# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class CgalCxx11 < Formula
  desc "Computational Geometry Algorithms Library (c++11)"
  homepage "https://www.cgal.org"
  url "https://github.com/CGAL/cgal/releases/download/v5.1.1/CGAL-5.1.1.tar.xz"
  sha256 "162250d37ab85017041ad190afa1ef5146f8b08ed908d890a64d8dbaa5910ca0"
  license "NOASSERTION"

  depends_on "cmake" => :build
  depends_on "qt" => [:build, :test]
  depends_on "boost"
  depends_on "eigen"
  depends_on "gmp"
  depends_on "mpfr"

  on_linux do
    depends_on "openssl@1.1"
  end

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    args = std_cmake_args + %W[
        -DCMAKE_CXX_FLAGS='-std=c++11'
        -DWITH_CGAL_Qt5=ON
        -DCGAL_HEADER_ONLY=OFF
    ]
    system "cmake", ".", *args
    system "make", "install" # if this fails, try separate make/make install steps
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test cgal`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "true"
  end
end
