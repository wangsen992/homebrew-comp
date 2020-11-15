# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Openfoam < Formula
  desc "OpenFOAM is a free, open source CFD software with an extensive range of features to solve anything from complex fluid flows"
  homepage "https://www.openfoam.com/"
  url "https://develop.openfoam.com/Development/openfoam/-/archive/OpenFOAM-v2006/openfoam-OpenFOAM-v2006.tar.gz"
  sha256 "07f0514e9f6f667902502b1a2e32a171e09c1dfce4fb2a2df598e6e2f4021b48"
  license ""

  # Third-party requirements
  depends_on "boost" 
  depends_on "cgal" 
  depends_on "fftw" 
  depends_on "scotch" 
  depends_on "hypre" 
  depends_on "cgns" 
  depends_on "gperftools" 

  # Parallel processing
  depends_on "open-mpi" 
  depends_on "adios2" 
  depends_on "scotch" 
  depends_on "kahip" 
  depends_on "metis" 

  depends_on "cmake" => :build

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    # system "cmake", ".", *std_cmake_args
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test openfoam-OpenFOAM-v`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
