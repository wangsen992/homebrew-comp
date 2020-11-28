# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class HypreAT210 < Formula
  desc "Parallel solvers for sparse linear systems featuring multigrid methods."
  homepage "https://www.llnl.gov/casc/hypre/"
  url "https://github.com/hypre-space/hypre/archive/V2-10-0b.tar.gz"
  sha256 "84cc763b8540b29c777a4010038b7d31824e02e4ef0dea21aba3afe96aad9a20"
  license "NOASSERTION"


  depends_on "gcc" 
  depends_on "open-mpi"

  keg_only :versioned_formula

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure
    system "./configure", "--prefix=#{prefix}",
                          "--with-MPI",
                          "--enable-bigint"
    system "make" , "install"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test hypre`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "true"
  end
end
