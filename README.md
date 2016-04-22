# shenc

shenc is a shell program to encrypt a file.
It produces self-decrypting shell program which depends on sh, openssl and a few standard tools.
It uses standard algorithms so encryption should be adequate for most purposes.
Please inspect the code before you use it. I did my best but I'm not a crypto expert.
Perform regular tests of encrypted files, bugs can and will happen.

You must enter pass phrase only the first time you are performing an encryption.
After that you can encrypt files without entering a pass phrase by specifying any previously encrypted file.
Its main use is for automated backups.

## Usage examples:

Encrypt the file a first time. You must enter the same password 3 times.
```
$ shenc <file >file.enc
Generating RSA private key, 2048 bit long modulus
...................................................+++
..........+++
e is 65537 (0x10001)
Enter pass phrase:
Verifying - Enter pass phrase:
Enter pass phrase:
writing RSA key
```

Encrypt another file with the same password. Now you won't be asked for a password.
```
$ shenc file.enc <another-file >another-file.enc
```

Decrypt encrypted files:
```
$ /bin/sh file.enc >file2
Enter pass phrase for /dev/fd/3:
$ cat another-file.enc | /bin/sh >another-file2
Enter pass phrase for /dev/fd/3:
```

## Encryption scheme for the first file

1. Generate 2048 bit RSA private key using `openssl genrsa`. Let it be `encrypted_rsa_private`. OpenSSL asks for a pass phrase 2 times.
2. Get RSA public key from `encrypted_rsa_private` using `openssl rsa`. Let it be `rsa_public`. OpenSSL asks for a pass phrase.
3. Generate 120-byte random data password using `openssl rand`. It's encoded using hex encoding. Let it be `data_password`.
4. Encrypt user file with AES-256-CBC using `openssl enc` with `data_password`. Let result be `encrypted_file`.
5. Encrypt `data_password` using `openssl rsautl` with `rsa_public`. Let result be `encrypted_data_password`.
7. Combine decrypt sh program, `rsa_public`, `encrypted_rsa_private`, `encrypted_data_password`, `encrypted_file`. It's the resulting encrypted file.

## Encryption scheme for subsequent files

1. Retrieve from previously encrypted file `rsa_public`, `encrypted_rsa_private` values.
2. Generate 120-byte random data password using `openssl rand`. It's encoded using hex encoding. Let it be `data_password`.
3. Encrypt user file with AES-256-CBC using `openssl enc` with `data_password`. Let result be `encrypted_file`.
4. Encrypt `data_password` using `openssl rsa` with `rsa_public`. Let result be `encrypted_data_password`.
5. Combine decrypt shell program, `rsa_public`, `encrypted_rsa_private`, `encrypted_data_password`, `encrypted_file`. It's the resulting encrypted file.

## Decryption scheme

1. Obtain previously encrypted file and retrieve `encrypted_rsa_private`, `encrypted_data_password`, `encrypted_file` from it.
2. Decrypt `encrypted_data_password` using `openssl rsautl` with `encrypted_rsa_private`. OpenSSL asks for a pass phrase. Let result be `data_password`.
3. Decrypt `encrypted_file` using `data_password`. It's the resulting user file.

## Notes

Encrypted format is very straightforward and self-explaining.
Program doesn't buffer file in memory, so you could encrypt huge files, send them via ssh, decrypt them there, etc,
without unnecessary memory consumption.
Overhead of encrypted file is about 4 KB. Encryption uses AES-256 and should be very fast on modern processors: around 100 MB/s on my laptop.

I tested that program with OS X 10.11, OpenBSD 5.9. It should work with any UNIX-like environment.
Please use `test/test.sh` to check if it works on your system.

I want this program and format to stay as simple and straightforward as possible, so it's unlikely that I'll add new features without a good reason.
