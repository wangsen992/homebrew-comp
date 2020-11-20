# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Su2 < Formula
  desc "Multiphysics Simulation and Design Software"
  homepage "https://su2code.github.io/"
  url "https://api.github.com/repos/su2code/SU2/tarball/v7.0.7"
  sha256 "a43f92f72e09229791840a3d86d28b6c885248f3ac4d54427fbeae66d17262a5"
  license ""

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "openmpi"
  depends_on "cgns"
  depends_on "openblas"
  depends_on "swig" 
  depends_on "mpi4py"

# TODO: set up std_meson_args 
# TODO: Figure out how the software is installed

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    prefix.mkpath
    prefix.install Dir["*"]

    meson_args = std_meson_args
    meson_args += [
      "--prefix=#{prefix}",
      "-Denable-autodiff=false", #those two are disabled otherwise there is compiler error
      "-Denable-directdiff=false", #NOTE: need to figure out why and then enable
      "-Denable-pywrapper=true",
      "-Dwith-mpi=auto",  #auto, enabled, disabled
      "-Dwith-omp=false", #experimental feature
      "-Denable-cgns=true", 
      "-Denable-tecio=true", 
      "-Denable-mkl=false",
      "-Denable-openblas=false", 
      "-Denable-pastix=false"
    ]
      
    Dir.chdir("#{prefix}") do
      # Note running meson.py could download additional packages, which should
      # be managed by homebrew. The current approach is bloated. 
      system "./meson.py", "build", *meson_args
      Dir.chdir("build") do
        system "ninja", "-v"
        system "ninja", "install", "-v"
      end
    end
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test v`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "true"
  end
end
