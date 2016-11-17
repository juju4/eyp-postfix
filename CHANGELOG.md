# CHANGELOG

## 0.2.1

* Mailserver with virtual users and domains
  * added **postfix::vmail** for virtual hosting
  * **INCOMPATIBLE CHANGE**: removed virtual_alias variable
  * added **postfix::vmail::alias**
  * **INCOMPATIBLE CHANGE**: changed default mailbox to **maildir**
  * virtual domains/accounts via **postfix::vmail::account**

## 0.1.58

* main.cf to concat
* added error support for **postfix::transport**

## 0.1.57

* added postfix::transport

## 0.1.56

**INCOMPATIBLE CHANGE**:
* option **relayhost_mx_lookup** to disable MX lookups for **relay_host** (disabled by default)

## 0.1.54

* added smtp_fallback_relay (array)
