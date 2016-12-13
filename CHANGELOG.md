# CHANGELOG

## 0.2.19

* bugfix: postmap & newaliases dependencies

## 0.2.18

* bugfix version detection

## 0.2.17

* dspam content filter

## 0.2.16

* stderr to /dev/null for facts eyp_postfix_uid & eyp_postfix_gid
* added postfix group to puppet management

## 0.2.15

* amavis support
* bugfix home_mailbox
* fixed acceptance testing
* added facts (eyp_postfix_uid/eyp_postfix_gid) to get postfix uid/gid

## 0.2.14

* postfix >= 2.9 compatibility for **opportunistic TLS**
* bugfix **postfix::sendercanonicalmap**
* /etc/aliases management

## 0.2.12

* **INCOMPATIBLE CHANGE** renamed **scmmap_to**, **scmmap_t**o to **scm_to**, **scm_from**

## 0.2.10

* added **postfix::sendercanonicalmap**

## 0.2.9

* removed **openssl** package management

## 0.2.8

* **INCOMPATIBLE CHANGE** added **resolve_null_domain**, default: **yes**

## 0.2.7

* improved compatibility for master.cf

## 0.2.5

* lint + cleanup
* reject_authenticated_sender_login_mismatch **postfix::vmail** in **smtpd_recipient_restrictions** and **smtpd_relay_restrictions**
* master.cf management using **concat**
* added **postfix::instance** (each **master.cf** item is a instance)
* added **postfix::contentfilter**
* added service_ensure & service_enable

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
