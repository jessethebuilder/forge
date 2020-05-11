# README

## Menus, Groups, and Products

### The Forge API

In the API, Products belong to Menus and Groups, and Groups belong to Menus, but
these associations are not enforced. An Account can have Group without a Menu or a
Product with neither, or even just a Menu, but no Group.

- Any application built with The Forge API should decide on a schema, stick to it,
  and document it. One example schema is below as The Forge Web settles on one.

### The Forge Web

#### Schema

- Menus -> Groups -> Products
- Groups -> Products
- Products
- Menus !! Products

#### In English

- Menu has Groups.
- Groups can be in a Menu or not, and has Product.
- Products can be in a Group or not.  
- Menus cannot have Products and Products cannot belong to Menus.

Applications using The Forge API should attempt to follow schema used by
The Forge Web,unless there is a compelling reason not to. Any Account using
The Forge Web should consume the app using values allowed by the schema, as there
is no way, via The Forge Web to create, say, a Product in a Menu (a Product would
have to be in a Group).

This means that any Account with multiple Menus, but no reason to use Groups will
generally have their Products in a Group called "Main" in each Menu.

## Forge in development

Run Forge locally with `RAILS_ENV=development foreman start`.
