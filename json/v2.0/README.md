# V2.0 SalesKing API Schema

The new version is not live yet! We put it here so one can follow the changes.

The following todo's are some of the things we are going to tackle.

## TODO

- [x] remove all deprecations
- [ ] move required attributes markup to top level object definition
- [ ] revise schema definitions for nested objects
- [ ] remove sub-status from documents status enum e.g overdue
- [ ] use oneOf definitions for nested items
- [ ] revise filter methods
- [ ] remove nested url's in favour of filter links instead e.g /emails?filter[contact_ids]=ID
- [ ] add type to nested objects reflecting the class
- [ ] change to/from filters to to_date/from_date
- [ ] add /teams
- [ ] move collection info to header ?
- [ ] define error object
- ..

## Server Side TODO

- [ ] remove prefixed nesting
- [ ] be more strict about validations e.g field length, strings vs number
- [ ] remove links in returned objects