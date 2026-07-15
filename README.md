# XICA
XICA (Cross-platform Image Capture Architecture) for Lazarus (Free Pascal) and Delphi

Leggi in: [Italiano](README.it.md)

# Description

XICA is a runtime only library. There are no visual components that have to be installed. 
Just add the package to dependancy/required of your Lazarus/Delphi Application and start using it.

The library aims to centralize various image acquisition libraries such as WIA, Twain, Sane, ICA, etc. 
so that a single manager can be used to enumerate and acquire images across various platforms. 
Obviously, if a library is limited to a single operating system, such as WIA, it will not be available on Linux/Mac.

# Library use

- There are no classes derived from TComponent, so you have to use it from code and free it by yourself (see the examples).
  For Lazarus use xica_pkg.lpk package 
  For Delphi use xica_dpkg.dpk package
  
- Supported Compilers:
  Lazarus / Free Pascal
  Delphi

See the changelog.txt file for change Log


(c) 2026 Massimo Magnano
