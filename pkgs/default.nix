{ pkgs ? import <nixpkgs> { system = "x86_64-linux"; config.allowUnfree = true; }
, ...
}:

#
# Library packages here are grouped by programming language
# and sorted alphabetically within those groups.
#

let
  inherit (pkgs)
    lib
    pythonPackages perlPackages haskellPackages
    stdenv fetchurl;
  inherit (lib) overrideDerivation;

  fns = {
    # make a statically linked version of a haskell package
    staticHaskellCallPackage = path: { cabal ? pkgs.haskellPackages.cabal
                                     , ...
                                     }@args:
      pkgs.haskellPackages.callPackage path (args // {
        cabal = cabal.override {
          enableSharedExecutables = false;
          enableSharedLibraries = false;
        };
      });

    buildPecl = import <nixpkgs/pkgs/build-support/build-pecl.nix> {
      inherit (pkgs) php stdenv autoreconfHook fetchurl;
    };
  };

in rec {
  inherit fns; # export functions as well

  angel = fns.staticHaskellCallPackage ./angel {};

  couchbase = pkgs.callPackage ./couchbase {};

  curl-loader = pkgs.callPackage ./curl-loader {};

  damemtop = pkgs.writeScriptBin "damemtop" ''
    #!${pkgs.bash}/bin/bash
    exec env PERL5LIB=${lib.makePerlPath (with perlPackages; [ AnyEvent GetoptLong TermReadKey YAML ])} \
      ${pkgs.perl}/bin/perl ${./memcached/damemtop} "$@"
  '';

  elasticsearch-cloud-aws = pkgs.stdenv.mkDerivation rec {
    name = "elasticsearch-cloud-aws-${version}";
    version = "2.4.1";
    src = fetchurl {
      url = "http://search.maven.org/remotecontent?filepath=org/elasticsearch/elasticsearch-cloud-aws/${version}/${name}.zip";
      sha256 = "1nvfvx92q9p0yny45jjfwdvbpn0qh384s6714wmm7qivbylb8f03";
    };
    phases = [ "installPhase" ];
    buildInputs = [ pkgs.unzip ];
    installPhase = ''
      mkdir -p $out/plugins/cloud-aws
      unzip $src -d $out/plugins/cloud-aws
    '';
  };

  erlang = pkgs.callPackage ./erlang {};

  gdb-quiet = stdenv.mkDerivation {
    name = "gdb-quiet";
    unpackPhase = ''
      true
    '';
    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cat > $out/bin/gdb << EOF
      #!/bin/sh
      exec ${pkgs.gdb}/bin/gdb -q -ex 'set auto-load safe-path /' "\$@"
      EOF
      chmod +x $out/bin/gdb

      runHook postInstall
    '';
  };

  go = pkgs.callPackage ./go/1.4.nix {};

  graphviz = pkgs.callPackage ./graphviz {};

  heavy-sync = with pythonPackages; pkgs.callPackage ./heavy-sync {
    inherit boto;
    inherit gcs-oauth2-boto-plugin;
    inherit sqlite3;
  };

  imagemagick = pkgs.callPackage ./ImageMagick {
    libX11 = null;
    ghostscript = null;
    tetex = null;
    librsvg = null;
  };

  incron = pkgs.callPackage ./incron {};

  jenkins = pkgs.callPackage ./jenkins {};

  kibana4 = pkgs.srcOnly {
    name = "kibana-4.0.0";
    src = fetchurl {
      url = https://download.elasticsearch.org/kibana/kibana/kibana-4.0.0-linux-x64.tar.gz;
      sha256 = "0bng4mmmhc2lhfk9vxnbgs4d7hiki5dlzrggzvd96dw0a8gy47cg";
    };
  };

  mariadb = pkgs.callPackage ./mariadb {};

  memcached-tool = pkgs.writeScriptBin "memcached-tool" ''
    #!${pkgs.bash}/bin/bash
    exec ${pkgs.perl}/bin/perl ${./memcached/memcached-tool} "$@"
  '';

  myrapi = fns.staticHaskellCallPackage ./myrapi { inherit servant servantClient; };

  mysql55 = pkgs.callPackage ./mysql/5.5.x.nix {};

  newrelic-java = pkgs.fetchurl {
    url = "https://download.newrelic.com/newrelic/java-agent/newrelic-agent/3.12.0/newrelic-agent-3.12.0.jar";
    sha256 = "1ssr7si7cbd1wg39lkgsi0nxnh5k0xjsbcjsnn33jm2khx7q0cji";
  };

  newrelic-memcached-plugin = pkgs.srcOnly rec {
    name = "newrelic_memcached_plugin-2.0.1";
    src = pkgs.fetchurl {
      url = "https://github.com/newrelic-platform/newrelic_memcached_java_plugin/raw/master/dist/${name}.tar.gz";
      sha256 = "16kyb42as8plabbfv8v3vhp6hjzxw1ry80ghf2zbkg0v4s1r5m6w";
    };
  };

  newrelic-mysql-plugin = pkgs.srcOnly rec {
    name = "newrelic_mysql_plugin-2.0.0";
    src = pkgs.fetchurl {
      url = "https://github.com/newrelic-platform/newrelic_mysql_java_plugin/raw/master/dist/${name}.tar.gz";
      sha256 = "158afq1q11bwjzcrsm860n8vj1xzdasql86b9qpwyhs4czjy0grd";
    };
  };

  newrelic-php = pkgs.callPackage ./newrelic-php {};

  newrelic-sysmond = pkgs.callPackage ./newrelic-sysmond {};

  nginx = overrideDerivation (pkgs.nginx.override { ngx_lua = true; }) (args: {
    configureFlags = args.configureFlags ++ ["--with-http_stub_status_module"];
  });

  percona-toolkit = import ./percona-toolkit { inherit perlPackages fetchurl; };

  pivotal_agent = pkgs.callPackage ./pivotal_agent {};

  rabbitmq = pkgs.callPackage ./rabbitmq { inherit erlang; };

  solr = pkgs.callPackage ./solr {};

  thumbor = (import ./thumbor { inherit pkgs newrelic-python statsd; }).thumbor;

  #
  # python libraries
  #

  helper = pythonPackages.buildPythonPackage rec {
    name = "helper-2.4.1";

    propagatedBuildInputs = with pythonPackages; [ pyyaml ];
    buildInputs = with pythonPackages; [ mock ];

    src = fetchurl {
      url = "https://pypi.python.org/packages/source/h/helper/${name}.tar.gz";
      md5 = "e7146c95bbd96a12df8d737a16dca3a7";
    };

    meta = with stdenv.lib; {
      description = "Helper";
      homepage = https://helper.readthedocs.org;
      license = licenses.bsd3;
    };
  };

  newrelic-python = import ./newrelic-python { inherit pkgs; };

  statsd = pythonPackages.buildPythonPackage rec {
    name = "statsd-3.0.1";

    src = fetchurl {
      url = "https://pypi.python.org/packages/source/s/statsd/${name}.tar.gz";
      md5 = "af256148584ed4daa66f50c30b5c1f95";
    };

    doCheck = false;

    propagatedBuildInputs = with pythonPackages; [];

    meta = with stdenv.lib; {
      homepage = https://github.com/jsocol/pystatsd;
      license = licenses.mit;
    };
  };

  #
  # haskell libraries
  #

  servant = pkgs.haskellPackages.callPackage ./servant {};
  servantClient = pkgs.haskellPackages.callPackage ./servant-client { inherit servant servantServer; };
  servantServer = pkgs.haskellPackages.callPackage ./servant-server { inherit servant waiAppStatic; };
  waiAppStatic = pkgs.haskellPackages.callPackage ./wai-app-static {};

  #
  # clojure/java libraries
  #

  clj-json = fetchurl {
    url = https://clojars.org/repo/clj-json/clj-json/0.5.3/clj-json-0.5.3.jar;
    sha256 = "1rwmmsvyvpqadv94zxzgn07qj0nf5jh0nhd218mk94y23l5mksxs";
  };

  elastisch = fetchurl {
    url = https://clojars.org/repo/clojurewerkz/elastisch/1.4.0/elastisch-1.4.0.jar;
    sha256 = "17nwcqh9wqvw0avi4lqgdma8qxfylif8ngv6sjdp84c8dn2i9rpf";
  };

  jackson-core-asl = fetchurl {
    url = "http://search.maven.org/remotecontent?filepath=org/codehaus/jackson/jackson-core-asl/1.9.9/jackson-core-asl-1.9.9.jar";
    sha256 = "15wq8g2qhix93f2gq6006fwpi75diqkx6hkcbdfbv0vw5y7ibi2z";
  };

  kiries = pkgs.fetchgit {
    url = https://github.com/threatgrid/kiries.git;
    rev = "dc9a6c76577f8dbfea6acdb6e43d9da13472a9a7";
    sha256 = "bf1b3a24e4c8e947c431e4a53d9a722383344e6c669eb5f86beb24539a25e880";
  };

  #
  # php libraries
  #

  imagick = fns.buildPecl {
    name = "imagick-3.1.2";
    sha256 = "14vclf2pqcgf3w8nzqbdw0b9v30q898344c84jdbw2sa62n6k1sj";
    buildInputs = [ pkgs.pkgconfig ];
    configureFlags = [
      "--with-imagick=${imagemagick}"
    ];

    NIX_CFLAGS_COMPILE = "-I${imagemagick}/include/ImageMagick-6";
  };
}
