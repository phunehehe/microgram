# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, base64Bytestring, blazeBuilder, blazeHtml, blazeMarkup
, byteable, cryptohash, cryptohashConduit, fileEmbed, filepath
, hspec, httpDate, httpTypes, mimeTypes, network
, optparseApplicative, systemFileio, systemFilepath, text, time
, transformers, unixCompat, unorderedContainers, wai, waiExtra
, warp, zlib
}:

cabal.mkDerivation (self: {
  pname = "wai-app-static";
  version = "3.0.0.6";
  sha256 = "0ilwlawffvib1p98q5jcc5m2i93n7iwmszwlbkb3ihlh1wz5q2b8";
  isLibrary = true;
  isExecutable = true;
  buildDepends = [
    base64Bytestring blazeBuilder blazeHtml blazeMarkup byteable
    cryptohash cryptohashConduit fileEmbed filepath httpDate httpTypes
    mimeTypes optparseApplicative systemFileio systemFilepath text time
    transformers unixCompat unorderedContainers wai waiExtra warp zlib
  ];
  testDepends = [
    hspec httpDate httpTypes mimeTypes network text time transformers
    unixCompat wai waiExtra zlib
  ];
  meta = {
    homepage = "http://www.yesodweb.com/book/web-application-interface";
    description = "WAI application for static serving";
    license = self.stdenv.lib.licenses.mit;
    platforms = self.ghc.meta.platforms;
  };
})