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
  depends_on "hypre" 
  depends_on "cgns" 
  depends_on "gperftools" 

  # Parallel processing
  depends_on "open-mpi" # already satisfied for building fftw
  depends_on "fftw" 
  depends_on "adios2" # Different C++ standard, build with -s => successful
  depends_on "brewsci-scotch" 
  depends_on "kahip"  # Different C++ standard, with -s, it states gmp has the same issue (ignored for now)
  depends_on "metis" 

  depends_on "cmake" => :build
  depends_on "m4" => :build
  depends_on "flex" => :build

  # NOTE: Helper scripts for sourcing the etc/bashrc file. 
  # Read in the bash environment, after an optional command.
  #   Returns Array of key/value pairs.
  def bash_env(cmd=nil)
    env = `#{cmd + ';' if cmd} printenv`
    env.split(/\n/).map {|l| l.split(/=/)}
  end

  # Source a given file, and compare environment before and after.
  #   Returns Hash of any keys that have changed.
  def bash_source(file)
    Hash[ bash_env(". #{File.realpath file}") - bash_env() ]
  end

  # Find variables changed as a result of sourcing the given file, 
  #   and update in ENV.
  def source_env_from(file)
    bash_source(file).each {|k,v| ENV[k] = v }
  end
 
  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure

    # source the environment to get ready for installation
    # NOTE: Figure out what to install into Cellar
    # Need the header files, tutorials, executables. 
    prefix.mkpath
    prefix.install Dir["*"]


    Dir.chdir prefix do
      # Override WM_PROJECT_DIR for HOMEBREW_FORMULA_PREFIX. 
      inreplace "#{prefix}/etc/bashrc", "export WM_PROJECT_DIR=\"$projectDir\"", 
        "export WM_PROJECT_DIR=#{prefix}\n echo $WM_PROJECT_DIR"
      source_env_from("#{prefix}/etc/bashrc")
      # Configure wmake to use -std=c++14
      system "for file in $(grep -rl c++11 .); do sed -i s/c++11/c++14/ $file; done"
      # Update dependency paths
      system "bin/tools/foamConfigurePaths", 
             "-openmpi-system",
             "-adios-path", Formula['adios2'].prefix,
             "-boost-path", Formula['boost'].prefix,
             "-cgal-path", Formula['cgal'].prefix,
             "-cmake-path", Formula['cmake'].prefix,
             "-fftw-path", Formula['fftw'].prefix,
             "-kahip-path", Formula['kahip'].prefix,
             "-metis-path", Formula['metis'].prefix, 
             "-scotch-path", Formula['brewsci-scotch'].prefix
      
      # gmp and mpfr setup requires special treatment
      (prefix/"etc/prefs.sh").write <<~EOS
        export GMP_ARCH_PATH=#{Formula['gmp'].prefix}
        export MPFR_ARCH_PATH=#{Formula['mpfr'].prefix}
      EOS
      # source again to read the prefs.sh
      source_env_from("#{prefix}/etc/bashrc")
      system "./Allwmake -j"
    end

    # NOTE: Make sure PATH includes homebrew_bin
    # NOTE: and include_path
    #ENV['CPATH'] = "#{HOMEBREW_PREFIX}/include"
    #ENV['PATH'] = "#{HOMEBREW_PREFIX}/bin:" + ENV['PATH']
    #system "#{prefix}/Allwmake -j"
    # system "cmake", ".", *std_cmake_args
  end

  def caveats
    s = <<~EOS
      Keg-only installation given the specific usage of the software.
      It is not yet used as dependencies for other packages.
      To use: 
        source #{prefix}/etc/bashrc 
      It may also be helpful to create a pref.sh file to modify the
      environment. 
      EOS
    s
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
    system "source #{prefix}/etc/bashrc"
    system "foamInstallationTest"
    system "true"
  end
end
