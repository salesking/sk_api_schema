# SalesKing API Changelog

See [commit messages](https://github.com/salesking/sk_api_schema/commits/) for details.
Also sign up to our [Developer Newsletter](http://www.salesking.eu/dev/newsletter/) to stay up-to-date !!!

##2014-01

* add SEPA creditor_id for company
* add SEPA fields for invoice, credit note: sepa_mandate_id, sepa_mandate_signed_at, sepa_debit_sequence_type
* add SEPA Export types, remove old dta export types
* search/filter contacts by organisation
* line_item price_single is required,
* line item empty tax,discount now return null instead of 0
* filter documents by products (product_ids)

##2013-12

* add cost_total, gross_margin to documents
* rename product.cost_price to cost

line_item:
* remove use_product switch. Now copy product fields into item whenever a product_id is set.
* remove required quantity and position, now defaulting to 1
* add cost, cost_total, gross_margin

##2013-10

* add net_total, gross_total to line item
* add category_name, cost_price fields to product

##2013-08

* fix docs for POST invoices/ID/payments to create payments
* add auto_send setting for recurring, opens invoice,creates pdf, sends email
* add recurring_id for invoices referencing the recurring from which the invoice was created
* add filter\[recurring_ids] to invoices
* add link to all invoices in recurring
* add filter\[status] to all documents
* add log field for emails, keeping potential error log
* add BCC, CC, FROM fields for email templates
* add items array to documents to be used instead of line_items
* Deprecate line_items **! doc.items vs doc.line_items !** ONLY use ONE as long as both items and line_items are present!
When updating objects we cannot figure out which array changed. In this case we
prefer line_items for backwards compatibility.
When using items: make sure to remove line_items before submitting an updated
document!

##2013-06

* add email filter "status" accepting sent,draft,in_progress strings, dropped sent/status filter

##2013-05

* add payment_reminder "status" and filter by "status"
* add payment "is_partial", replaces the "new_doc_status" parameter on POST create. Partial payments dont close the related document.
* add payment "cash_discount", to explicitly set the cash discount amount withdrawn by a client
* add "late_fee" to payments, for convient creation of a second payment for the last payment_reminder of an invoice

##2013-04

* filter attachments by related_object_type
* new PubSub channel for attachments
* new attachments/{ID}/download url DEPRECATE attachment.url
* add lead_date to contact
* make contact.lead_ref + lead_source text fields

##2013-03

* add path method to schema: SK::Api::Schema.path

##2013-01

Contacts/Client changes
* New contact resource sporting client, lead, supplier contact types
* mark contact as employee, getting number, organisation, vat/tax number from his parent
* nested contacts
* add contact, contact_id to all documents
* add parent_id to contact, for contact nesting
* remove client_id from param sort_by for doc list views (it makes no sense to sort by a UUID)
* export_template, email_template.kind uses contact instead of client

DEPRECATED removed ~ 08.2013 prior notice via [Developer Newsletter](http://www.salesking.eu/dev/newsletter/)
* client resource
* document.client, document.client_id => doc.contact, doc.contact_id
* documents?filter\[client_ids] => filter\[contact_ids]
* oAuth scope for api/clients

Others
* add external_ref for line item
* email "send" parameter can be set to false or 0 to prevent sending
* email "from_addr" is not required
* add new item types: devider_item, sub_total_item
* add items for documents containing all items by type
* add filter\[tags] to products, mark price as required
* add name-key to all objects containing the lowercased_underscored-name, PLEASE start using it instead of the title-field, which will be changed to its CamelCasedObjectName

##2012-12
* add search filter to pdf_template, email_template
* filter clients by ids - search for a list of comma separated uuids

##2012-11
* add currency fields for documents, client, company and payment
* add PDF template resource
* drop 'method' from payment in favour of payment_method

##2012-07
* maxLength for all string properties with limits
* add "format":"text" to plain-text fields
* search products by number

##2012-06
* line item discount can be negative
* tax and discount values with up to four decimal places
* add payments link to invoice, credit_note
* add due_date and due_days to order
* Deprecate payment.method in favour of payment.payment_method bcs 'method' is a keyword in programming
* test with travis-ci.org

##2012-05
* fix date type definitions
* add empty links sections for address, line_item
* add payment_method to order
* deprecate gross_total for payment reminder

##2012-01
* add notes field for client

##2012-05

* add missing payment method to order
* fix date & date-time type definitions
* add empty links section to address, line item

##2011-10
* added created_at search filter to clients and documents
* added creator(user) search filter to clients and documents

##2011-9
* search documents by number
* maxLength information for client and address properties
* allow tags edit, destroy

##2011-7
* allow new documents with status closed
* auto-set number+date for new open/closed documents

##2011-6
* added language field to document, client, email-template
* added filter\[languages] for documents and clients, to search by one or more languages
* added filter\[client_ids] to documents, to search by one or multiple clients
* added filter\[ids] for documents, to find multiple specific documents
* changed _delete property to _destroy for address, line_item
* removed client_id requirement for documents

##2011-05
* new hash_clean method for ruby schema reader class

##2011-04
* added tags
* added documents
* reduced default objects in list to 10, max is 100
* added field parameter to limit returned fields in ruby to_hash_from_schema & SK
* added created_at & number filtering to client
* added _delete field to line_item & address, to be able to destroy them since both are transfered within their parent object

##2011-03
* added subscriptions
* added memoizing to ruby schema reader

##2011-02
* added moneybookers, premium_sms to payment methods
* added auth_permission
* added external_ref to documents
* added company
* added recurring
* added source param to copy documents

##2010-11 - 2011-01
* initial version
