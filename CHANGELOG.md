# CHANGELOG

## 0.2.30

* added regex support to **postfix::vmail::alias**

## 0.2.29

* added variable **message_size_limit** as per [Issue#44](https://github.com/NTTCom-MS/eyp-postfix/issues/44)

## 0.2.28

* added **postfix::canonicalmap** to be able to manage **canonical_maps**

## 0.2.27

* modified **postfix::transport** to be able to have multiple puppet managed transport files

## 0.2.26

* added **smtpd_reject_footer**

## 0.2.25

* added **smtp_generic_maps** management (default: */etc/postfix/generic_maps*) using **postfix::genericmap**

## 0.2.24

* lint

## 0.2.23

* added **data_directory** as a variable

## 0.2.22

* added Ubuntu 16.04 support

## 0.2.21

* improved main.cf for clarity (debug peer, debug level)
* added syslog_name

## 0.2.20

* modified openssl cert generation to be able to change it's CN

## 0.2.19

* bugfix: postmap & newaliases dependencies
* debug peer, debug level and smtpd debug

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

* **INCOMPATIBLE CHANGE** renamed **scmmap_to** and **scmmap_to** to **scm_to** and **scm_from**

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
