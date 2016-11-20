# CHANGELOG

## 0.2.3

* lint + cleanup
* reject_authenticated_sender_login_mismatch **postfix::vmail** in **smtpd_recipient_restrictions** and **smtpd_relay_restrictions**
* master.cf management using **concat**
* added **postfix::instance** (each **master.cf** item is a instance)
* added **postfix::contentfilter**

## 0.2.2

* added **permit_inet_interfaces** by default to **smtpd_recipient_restrictions** and **smtpd_relay_restrictions**

## 0.2.1

* Mailserver with virtual users and domains
  * added **postfix::vmail** for virtual hosting using **eyp-dovecot**
  * **INCOMPATIBLE CHANGE**: removed virtual_alias variable
  * added **postfix::vmail::alias**
  * **INCOMPATIBLE CHANGE**: changed default mailbox to **maildir**
  * virtual domains/accounts via **postfix::vmail::account**
  * **dovecot** based auth - using **eyp-dovecot**

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
