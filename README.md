# shenc

shenc is a shell program for file encryption using asymmetric cryptography.
It allows to encrypt a file without pass phrase.
Its main use is to encrypt automated backups, though you might find other use cases.

An entire encryption scheme depends on a secure pass phrase.
I recommend you to use at least 12-length alphanumeric random password.
You can use the following command to generate a good password: `openssl rand -base64 9`.

shenc uses standard algorithms (RSA with 2048 bit key, AES-128-CBC)
so the encryption should be adequate in most cases.
Please inspect the code before you use it. I did my best but I'm not a crypto expert.
Perform regular tests of encrypted files, bugs can and will happen.

shenc depends on openssl and a few standard shell utilities.
You can encrypt or decrypt without `shenc` utility, because a key file for encryption and an encrypted file
are shell scripts and can be executed using /bin/sh. Or you can use shenc if you don't trust those files.

## Usage examples:

shenc uses standard input/output streams. Just use shell redirection to use files or you can construct
complex pipelines.

Generate a key file. It should be done once and you will use that file to encrypt your files.
You'll be asked for a pass phrase 3 times. Please enter the same pass phrase.
OpenSSL will only check that your pass phrase is at least 4 characters long.
Of course 4 characters is too short, so please use something better.
```
$ shenc --generate-key > key-file.sh
Generating RSA private key, 2048 bit long modulus
..............+++
...............................................................+++
e is 65537 (0x10001)
Enter pass phrase:
Verifying - Enter pass phrase:
Enter pass phrase:
writing RSA key
```

Encrypt a file using the key file which was generated in the previous step. You won't be asked for a pass phrase.
```
$ shenc --encrypt key-file.sh <file >file.enc.sh
```

Also you can use the key file as a shell script to encrypt a file.
You don't need `shenc` utility in this case.
Please ensure that `key-file.sh` came from a trusted source.
```
$ /bin/sh key-file.sh <file >file.enc.sh
```

Decrypt encrypted file. You'll be asked for a pass phrase. You don't need key file to decrypt, encrypted file contains
everything required.
```
$ shenc --decrypt <file.enc.sh >file
Enter pass phrase for /dev/fd/3:
```

Also you can use an encrypted file as a shell script to decrypt itself. You don't need `shenc` utility in this case.
Please ensure that `file.enc.sh` came from a trusted source.
```
$ /bin/sh file.enc.sh > file
Enter pass phrase for /dev/fd/3:
```

## Key file generation scheme

1. Generate 2048 bit RSA private key using `openssl genrsa`. Let it be `encrypted_rsa_private`. OpenSSL asks for a pass phrase 2 times.
2. Get RSA public key from `encrypted_rsa_private` using `openssl rsa`. Let it be `rsa_public`. OpenSSL asks for a pass phrase.
3. Combine encrypt shell program, `encrypted_rsa_private` and `rsa_public`. It's the resulting key file.

## Encryption scheme

1. Retrieve `rsa_public`, `encrypted_rsa_private` values from the key file.
2. Generate 120-byte random data password using `openssl rand`. It's encoded using hex encoding. Let it be `data_password`.
3. Encrypt user file with AES-256-CBC using `openssl enc` with `data_password`. Let the result be `encrypted_file`.
4. Encrypt `data_password` using `openssl rsa` with `rsa_public`. Let the result be `encrypted_data_password`.
5. Combine decrypt shell program, `encrypted_rsa_private`, `encrypted_data_password`, `encrypted_file`. It's the resulting encrypted file.

## Decryption scheme

1. Retrieve `encrypted_rsa_private`, `encrypted_data_password`, `encrypted_file` values from the encrypted file.
2. Decrypt `encrypted_data_password` using `openssl rsautl` with `encrypted_rsa_private`. OpenSSL asks for a pass phrase. Let the result be `data_password`.
3. Decrypt `encrypted_file` using `data_password`. It's the resulting user file.

## Notes

Key file and encrypted file formats are very straightforward and self-explaining.
Program doesn't buffer file in memory, so you could encrypt huge files, send them via ssh, decrypt them there, etc,
without any extra memory consumption.
Overhead of encrypted file is about 3.5 KB. Encryption uses AES-256 and should be very fast on modern processors: around 500 MB/s on my laptop.
You can use `shenc --extract-key <file.enc.sh >key-file.sh` to extract a key file from an existing encrypted file.

I tested that program with OS X 10.11, OpenBSD 5.9. It should work with any UNIX-like environment.
Please use `test/test.sh` to check if it works on your system. Also you can use `test/perf.sh` to check performance.

I want this program and formats to stay as simple and straightforward as possible,
so it's unlikely that I'll add new features without a good reason.
