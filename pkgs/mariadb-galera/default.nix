{ stdenv, fetchurl, cmake, bison, ncurses, openssl, readline, zlib, perl }:

stdenv.mkDerivation rec {
  name = "mariadb-galera-${version}";
  version = "10.0.17";

  src = fetchurl {
    url = "https://downloads.mariadb.org/interstitial/${name}/source/${name}.tar.gz";
    md5 = "c9da022abc6023b06320c31ae26a0f2e";
  };

  buildInputs = [ cmake bison ncurses openssl perl readline zlib ]
     ++ stdenv.lib.optional stdenv.isDarwin perl;

  enableParallelBuilding = true;

  cmakeFlags = [
    "-DWITH_SSL=yes"
    "-DWITH_READLINE=yes"
    "-DWITH_EMBEDDED_SERVER=no"
    "-DWITH_ZLIB=yes"
    "-DHAVE_IPV6=yes"
    "-DWITHOUT_TOKUDB=1"
    "-DINSTALL_SCRIPTDIR=bin"
    # Galera Cluster:
    "-DWITH_WSREP=ON"
    "-DWITH_INNODB_DISALLOW_WRITES=1"
  ];

  NIX_LDFLAGS = stdenv.lib.optionalString stdenv.isLinux "-lgcc_s";

  prePatch = ''
    sed -i -e "s|/usr/bin/libtool|libtool|" cmake/libutils.cmake
  '';
  postInstall = ''
    sed -i -e "s|-lssl|-L${openssl}/lib -lssl|g" $out/bin/mysql_config
    sed -i -e "s|basedir=\"\"|basedir=\"$out\"|" $out/bin/mysql_install_db
    # https://github.com/NixOS/nixpkgs/issues/7117
    rm -r $out/mysql-test $out/sql-bench $out/data # Don't need testing data
    rm $out/share/man/man1/mysql-test-run.pl.1
    rm $out/bin/rcmysql # Not needed with nixos units
    rm $out/bin/mysqlbug # Encodes a path to gcc and not really useful
    find $out/bin -name \*test\* -exec rm {} \;
  '';

  meta = {
    homepage = https://mariadb.com/kb/en/mariadb/what-is-mariadb-galera-cluster/;
    description = "MariaDB Galera Cluster is a synchronous multi-master cluster for MariaDB.";
  };
}
