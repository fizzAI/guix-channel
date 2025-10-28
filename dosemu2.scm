(define-module (dosemu2))

(use-modules (guix packages)
             (guix download)
             (guix build-system gnu)
             (guix build-system meson)
             (guix licenses)
             (guix git-download)
             (guix gexp)
             (gnu packages flex)
             (gnu packages m4)
             (gnu packages bison)
             (gnu packages autotools)
             (gnu packages pkg-config)
             (gnu packages ncurses)
             (gnu packages elf)
             (gnu packages code)
             (gnu packages commencement)
             (gnu packages assembly))

(define-public thunk_gen (package
  (name "thunk_gen")
  (version "1.8")
  (source (origin
            (method git-fetch)
            (uri (git-reference
                      (url "https://github.com/stsp/thunk_gen")
                      (commit version)))
            (sha256
             (base32
              "0j92frnhvrxr5wv4xdvh1ynjr8j05w7plmxv6z48z5fn5mv55rsc"))))
  (build-system meson-build-system)
  (native-inputs
   (list flex m4 bison))
  (synopsis "generator for C and assembler thunks")
  (description
   "This is a generator for C and assembler thunks. It is likely not interesting for you unless you want to compile some 16bit or 32bit DOS code for 64-bits execution.")
  (home-page "https://github.com/stsp/thunk_gen")
  (license gpl3)))

(define-public smaller_c 
(let ((commit "1865d79ce7a5ad3f8a9515a571437cee084b8b1d")
      (revision "2"))
(package
  (name "SmallerC")
  (version (git-version "0.1" revision commit))
  (source (origin
            (method git-fetch)
            (uri (git-reference
                      (url "https://github.com/alexfru/SmallerC")
                      (commit commit)))
            (sha256
             (base32
              "0f9j9jsdkg0k1gvps77l6ccyf2vnlgw88lnkhm2fhwfd24ga8vhq"))))
  (build-system gnu-build-system)
  (arguments
    `(
      #:make-flags (list (string-append "prefix=" (assoc-ref %outputs "out")) "CC=gcc")
      #:phases
      (modify-phases %standard-phases
        (delete 'check))))
  (native-inputs
    (list gcc-toolchain nasm))
  (inputs
    (list nasm))
  (synopsis "Simple C compiler")
  (description
   "Smaller C is a simple and small single-pass C compiler,
currently supporting most of the C language common between C89/ANSI C
and C99 (minus some C89 and plus some C99 features).")
  (home-page "https://github.com/alexfru/SmallerC")
  (license bsd-2))))

(define-public djstub
(let ((commit "fc6d24c9fd82ab68fa8bb66f5f9be4806b6193ad")
      (revision "1"))
(package
  (name "djstub")
  (version (git-version "0.7" revision commit))
  (source (origin
            (method git-fetch)
            (uri (git-reference
                      (url "https://github.com/fizzAI/djstub")
                      (commit commit)))
            (sha256
             (base32
              "06fxxjppkzl7p7skjz425754nkbhcicggc7h3fxn6xv00ak15w1j"))))
  (build-system gnu-build-system)
  (arguments
    `(
      #:make-flags (list (string-append "prefix=" (assoc-ref %outputs "out")) "CC=gcc" "STUBCC=smlrcc")
      #:phases
      (modify-phases %standard-phases
        (delete 'configure)
        (delete 'check))))
  (native-inputs
    (list gcc-toolchain smaller_c nasm))
  (synopsis " go32-compatible stub that supports COFF, PE and ELF payloads ")
  (description
   "djstub project provides a dj64-compatible and go32-compatible stubs that support COFF, PE and ELF payloads. Its primary target is dj64dev suite, but it can also work with djgpp-built executables.")
  (home-page "https://github.com/stsp/djstub")
  (license bsd-2))))


(define-public dj64dev (package
  (name "dj64dev")
  (version "0.4-3")
  (source (origin
            (method git-fetch)
            (uri (git-reference
                      (url "https://github.com/stsp/dj64dev")
                      (commit version)))
            (sha256
             (base32
              "0zg9iqmfvli4map8h4w9rfk84sclqy772lfjiym22iw96jnyjmah"))))
  (build-system gnu-build-system)
  (arguments
    `( 
      #:configure-flags '("--disable-ncurses")
      #:phases
      (modify-phases %standard-phases
        (add-before 'configure 'autoconf
                (lambda* (#:key outputs #:allow-other-keys)
                         (invoke "./autogen.sh")))
        (delete 'check))))
  (native-inputs
   (list thunk_gen
         autoconf automake flex m4 bison pkg-config libelf-shared universal-ctags))
  (inputs
    (list thunk_gen djstub libelf-shared))
  (synopsis "dj64dev development suite")
  (description
   "dj64dev is a development suite that allows to cross-build 64-bit programs for DOS. It consists of 2 parts: dj64 tool-chain and djdev64 suite.")
  (home-page "https://github.com/stsp/dj64dev")
  (license gpl3+)))


(define-public dosemu2 (package
  (name "dosemu2")
  (version "2.0pre9-2")
  (source (origin
            (method git-fetch)
            (uri (git-reference
                      (url "https://github.com/dosemu2/dosemu2")
                      (commit (string-append "dosemu2-" version))))
            (sha256
             (base32
              "09j7xhssc0bb5d6c9d1nm4s28p0hspx7izq48fj3bwyi7mvf2q0k"))))
  (build-system gnu-build-system)
  (arguments
    `( 
      #:configure-flags '("--disable-ncurses" "--disable-fdpp")
      #:phases
      (modify-phases %standard-phases
        (add-before 'configure 'autoconf
                (lambda* (#:key outputs #:allow-other-keys)
                         (invoke "./autogen.sh")))
        (delete 'check))))
  (native-inputs
   (list thunk_gen dj64dev
         autoconf automake flex m4 bison pkg-config libelf-shared universal-ctags))
  (inputs
    (list libelf-shared))
  (synopsis "dj64dev development suite")
  (description
   "dj64dev is a development suite that allows to cross-build 64-bit programs for DOS. It consists of 2 parts: dj64 tool-chain and djdev64 suite.")
  (home-page "https://github.com/stsp/dj64dev")
  (license gpl3+)))
