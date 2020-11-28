# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Trilinos < Formula
  desc "Primary repository for the Trilinos Project"
  homepage "https://trilinos.org/"
  url "https://github.com/trilinos/Trilinos/archive/trilinos-release-13-0-1.tar.gz"
  sha256 "0bce7066c27e83085bc189bf524e535e5225636c9ee4b16291a38849d6c2216d"
  license "NOASSERTION"

  depends_on "gcc" => :build
  depends_on "cmake" => :build
  depends_on "openmpi"
  depends_on "metis"
  depends_on "openblas"
  depends_on "adios2"
  depends_on "openblas"
  depends_on "hdf5-mpi"
  depends_on "netcdf"
  depends_on "zlib"
  depends_on "hypre@2.10" # test if earlier versions work. 
  depends_on "boost"
  depends_on "eigen"
  depends_on "wangsen992/comp/cgal-cxx11" #Make sure cgal in non header-only mode
  depends_on "superlu" # must specify SuperLU5 API support in cmake flags
  depends_on "brewsci/num/brewsci-scotch"
  depends_on "brewsci/num/brewsci-parmetis"

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    cmake_args = std_cmake_args
    # cgal is compiled with cxx11
    cmake_args = cmake_args + %W[
            -DCMAKE_C_COMPILER=#{Formula['open-mpi'].bin/"mpicc"}
            -DCMAKE_CXX_COMPILER=#{Formula['open-mpi'].bin/"mpic++"}
            -DCMAKE_Fortran_COMPILER=#{Formula['open-mpi'].bin/"mpif90"}
            -DCMAKE_CXX_STANDARD=11
            -DCMAKE_CXX_STANDARD_REQUIRED=ON
            -DCMAKE_CXX_EXTENSIONS=OFF
            -DCMAKE_INSTALL_PREFIX=#{prefix}
            ]

    # parmetis version 4.0.3 not recognized, special flag to enforce
    # See Line 154-155 in link below: 
    # https://github.com/dealii/candi/blob/master/deal.II-toolchain/packages/trilinos.package
    # MueLu has build error also related with cgal, so
    cmake_se_all = %W[
            -DTrilinos_ENABLE_ALL_PACKAGES=ON
          ]
    cmake_se_args = %W[
            -DTrilinos_ENABLE_Tpetra=ON
            -DTrilinos_ENABLE_Kokkos=ON
            -DTrilinos_ENABLE_Muelu=ON
            -DMeuLu_ENABLE_Tutorial=OFF
            -DTrilinos_ENABLE_Ifpack2=ON
            -DTrilinos_ENABLE_Teuchos=ON
            -DTrilinos_ENABLE_Belos=ON
            -DTrilinos_ENABLE_Amesos2=ON
            -DTrilinos_ENABLE_NOX=ON
            -DTrilinos_ENABLE_LOCA=ON
            -DTrilinos_ENABLE_ROL=ON
            -DTrilinos_ENABLE_Anasazi=ON
            -DTrilinos_ENABLE_Sacado=ON
            -DTrilinos_ENABLE_Stokhos=ON
            -DTrilinos_ENABLE_Panzer=ON
            -DTrilinos_ENABLE_Intrepid2=ON
            -DTrilinos_ENABLE_Phalanx=ON
            -DTrilinos_ENABLE_Compadre=ON
            -DTrilinos_ENABLE_EpetraExt=OFF
          ]
    # NOTE:
    # for superlu on amesos: https://github.com/trilinos/Trilinos/pull/1643
    # hypre is turned off due to compilation error
    # CGAL sweep.h resulted in the system cgal being used. Must enforce its
    # version. 
    cmake_tpl_args = %W[
            -DTPL_ENABLE_MPI=ON
            -DMPI_BASE_DIR=#{Formula['open-mpi'].prefix}
            -DTPL_ENABLE_OPENMP=ON
            -DTrilinos_ENABLE_OpenMP=ON
            -DOPENMP_LIBRARY_DIRS=#{Formula['libomp'].lib}
            -DTPL_ENABLE_METIS=ON
            -DBLAS_LIBRARY_DIRS=#{Formula['openblas'].lib}
            -DTPL_ENABLE_METIS=ON
            -DMETIS_LIBRARY_DIRS=#{Formula['metis'].lib}
            -DTPL_ENABLE_PARMETIS=ON
            -DHAVE_PARMETIS_VERSION_4_0_3=ON
            -DPARMETIS_LIBRARY_DIRS=#{Formula['brewsci-parmetis'].lib}
            -DTPL_ENABLE_Scotch=ON
            -DScotch_LIBRARY_DIRS=#{Formula['brewsci-scotch'].lib}
            -DTPL_ENABLE_ADIOS2=OFF
            -DADIOS2_LIBRARY_DIRS=#{Formula['adios2'].lib}
            -DTPL_ENABLE_HDF5=ON
            -DHDF5_LIBRARY_DIRS=#{Formula['hdf5-mpi'].lib}
            -DTPL_ENABLE_Netcdf=ON
            -DNetcdf_LIBRARY_DIRS=#{Formula['netcdf'].lib}
            -DTPL_ENABLE_Zlib=ON
            -DZlib_LIBRARY_DIRS=#{Formula['zlib'].lib}
            -DTPL_ENABLE_HYPRE=OFF
            -DHYPRE_LIBRARY_DIRS=#{Formula['hypre@2.10'].lib}
            -DTPL_ENABLE_Boost=ON
            -DBoost_LIBRARY_DIRS=#{Formula['boost'].lib}
            -DTPL_ENABLE_CGAL=ON
            -DCGAL_LIBRARY_DIRS=#{Formula['cgal-cxx11'].lib}
            -DCGAL_INCLUDE_DIRS=#{Formula['cgal-cxx11'].include/"CGAL"}
            -DTPL_CGAL_INCLUDE_DIRS=#{Formula['cgal-cxx11'].include/"CGAL"}
            -DTPL_ENABLE_Eigen=ON
            -DEigen_LIBRARY_DIRS=#{Formula['eigen'].lib}
            -DEigen_INCLUDE_DIRS=#{Formula['eigen'].include/"eigen3"}
            -DTPL_ENABLE_SuperLU=ON
            -DSuperLU_LIBRARY_DIRS=#{Formula['superlu'].lib}
            -DSuperLU_INCLUDE_DIRS=#{Formula['superlu'].include/"superlu"}
            -DTrilinos_ENABLE_SuperLU5_API=ON
            -DML_ENABLE_SuperLU:BOOL=OFF
            -DMeuLu_ENABLE_SuperLU:BOOL=OFF
            -DTPL_ENABLE_Matio=OFF
    ]
            
    mkdir "build" do
      system "cmake", "..", *cmake_args, *cmake_se_args, *cmake_tpl_args
      system "make", "-j2" # if this fails, try separate make/make install steps
      system "make", "install"
    end
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test Trilinos`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "true"
  end
end
