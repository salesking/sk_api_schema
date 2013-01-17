# Changelog for SalesKing API Schema

A more detailed view of the changes can be found in the {commit messages}[https://github.com/salesking/sk_api_schema/commits/]

2013-01
* add external_ref for line item
* email "send" parameter can be set to false or 0 to prevent sending
* email "from_addr" is not required
* add new item types: devider_item, sub_total_item
* add items for documents containing all items by type
* add filter\[tags] to products, mark price as required
* add name-key to all objects containing the lowercased_underscored-name, PLEASE start using it instead of the title-field, which will be changed to its CamelCasedObjectName

2012-12
* add search filter to pdf_template, email_template
* filter clients by ids - search for a list of comma separated uuids

2012-11
* add currency fields for documents, client, company and payment
* add PDF template resource
* drop 'method' from payment in favour of payment_method

2012-07
* maxLength for all string properties with limits
* add "format":"text" to plain-text fields
* search products by number

2012-06
* line item discount can be negative
* tax and discount values with up to four decimal places
* add payments link to invoice, credit_note
* add due_date and due_days to order
* Deprecate payment.method in favour of payment.payment_method bcs 'method' is a keyword in programming
* test with travis-ci.org

2012-05
* fix date type definitions
* add empty links sections for address, line_item
* add payment_method to order
* deprecate gross_total for payment reminder

2012-01
* add notes field for client

2012-05

* add missing payment method to order
* fix date & date-time type definitions
* add empty links section to address, line item

2011-10
* added created_at search filter to clients and documents
* added creator(user) search filter to clients and documents

2011-9
* search documents by number
* maxLength information for client and address properties
* allow tags edit, destroy

2011-7
* allow new documents with status closed
* auto-set number+date for new open/closed documents

2011-6
* added language field to document, client, email-template
* added filter\[languages] for documents and clients, to search by one or more languages
* added filter\[client_ids] to documents, to search by one or multiple clients
* added filter\[ids] for documents, to find multiple specific documents
* changed _delete property to _destroy for address, line_item
* removed client_id requirement for documents

2011-05
* new hash_clean method for ruby schema reader class

2011-04
* added tags
* added documents
* reduced default objects in list to 10, max is 100
* added field parameter to limit returned fields in ruby to_hash_from_schema & SK
* added created_at & number filtering to client
* added _delete field to line_item & address, to be able to destroy them since both are transfered within their parent object

2011-03
* added subscriptions
* added memoizing to ruby schema reader

2011-02
* added moneybookers, premium_sms to payment methods
* added auth_permission
* added external_ref to documents
* added company
* added recurring
* added source param to copy documents

2010-11 - 2011-01
* initial version
