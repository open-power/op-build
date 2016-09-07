# Important Information About Secure and Trusted Boot And Signing Keys

## Background

IBM P8 OpenPOWER systems support a limited set of Secure and Trusted Boot
functionality.  Secure Boot implements a processor based chain of trust. The
chain starts with an implicitly trusted component with other components being
authenticated and integrity checked before being executed on the host processor
cores.  At the root of this trust chain is the Host Platform Core Root of Trust
for Measurement (CRTM). Immutable Read Only Memory (ROM - fixed in the P8
processor chip) verifies the initial firmware load. That firmware verifies
cryptographic signatures on all subsequent "to be trusted" firmware that is
loaded for execution on the P8 cores.  Trusted Boot also makes use of this same
CRTM by measuring and recording FW images via a Trusted Platform Module
(TPM) before control is passed on to the next layer in the boot stack. The CRTM
design is based on a Public Key Infrastructure (PKI) process to validate the
firmware images before they are executed. This process makes use of a set of
hardware and firmware asymmetric keys.  Multiple organizations will want to
deliver POWER hardware, digitally signed firmware, signed boot code,
hypervisors, and operating systems. Each platform manufacturer wants to maintain
control over its own code and sign it with its own keys. A single key hash is
stored in host processor module SEEPROM representing the anchoring root set of
hardware keys. The P8 Trusted Boot supports a key management flow that makes use
of two kinds of hardware root keys, a wide open, well-known, openly published
public/private key pair (imprint keys) and a set of production keys where the
private key is protected by a hardware security module (HSM) internal to the
manufacturing facility of the key owner.

## Purpose Of Imprint Public/Private Keys

It is critical to note that the imprint keys are not to be used for production
mode. These are strictly for manufacturing and development level support given
the open nature of the private part of the HW and FW keys. This allows
developers and testers to sign images and create builds for Secure and Trusted
Boot development lab testing. Systems must be transitioned to production level
keys for customer environments.

## Manufacturer Key Management Role

If a system is shipped from the System Manufacturer with imprint keys installed
rather than production level hardware keys, the system must be viewed as running
with a set of well-known default keys and vulnerable to exploitation.  The
System Access Administrator must work with the System Manufacturer to insure
that a key transition process is utilized once a hardware based chain of trust
is to be enabled as part of Secure or Trusted Boot functionality.

## Intentional Public Release Of Imprint Public/Private Keys

All public and private keys in this directory are being intentionally released
to enable the developer community to sign code images.  For true security, a
different set of production signing keys should be used, and the private
production signing key should be carefully guarded.  Currently, we do not yet
support production key signing through a signing server, only development
signing.

### Imprint Private Keys

#### Hardware Private Keys

hw_key_a.key
hw_key_b.key
hw_key_c.key

#### Software Private Keys

sw_key_a.key

While three software keys are possible, for development we currently use one
software key

### Imprint Public Keys (binary)

#### Hardware Public Keys

hw_key_a.pem
hw_key_b.pem
hw_key_c.pem

The default hardware key hash in the P8 SEEPROM can be obtained by stripping the
leading byte of each hardware public key, concatenating the results in the order
listed, and computing the sha512 hash of the result.  The hash_keys.bash script
automates this computation.

These keys can also be derived from the HW public keys above

#### Software Private Keys (binary)

sw_key_a.pem


