# NAME

Perl::Critic::Policy::Subroutines::ProhibitUnderscorePrivateSubs - Make a private sub lexical, rather than private by a leading underscore.

# VERSION

version 0.001

# Perl::Critic::Policy::Subroutines::ProhibitUnderscorePrivateSubs

A leading underscore says that a sub is private, and nothing enforces it.  Any
code can call `Some::Module::_helper`, a subclass can override it without
knowing, and a test that calls it pins the implementation instead of the
interface.  A lexical sub is private in fact: nothing outside its scope can
name it.

```perl
sub _helper { ... }                  # reported
_helper(@args);

my sub helper { ... }                # perl 5.26 and later
helper(@args);

my $helper = sub { ... };            # any perl
$helper->(@args);
$self->$helper(@args);               # called as a method
```

## PROHIBITED

```perl
sub _helper { ... }
sub _helper;                         # a forward declaration
sub Some::Module::_helper { ... }    # the last part of the name counts
our sub _helper { ... }              # our is a package sub
```

## ALLOWED

```perl
my sub helper { ... }
state sub helper { ... }
my $helper = sub { ... };
sub helper { ... }                   # public, and named so
sub _build_thing { ... }             # when allow names it, see PARAMETERS
```

# PARAMETERS

`allow` is a list of names, separated by whitespace, that the policy leaves
alone.  Use it for a name that another module requires to be a package sub,
such as a builder that an object system looks up by name:

```
[Subroutines::ProhibitUnderscorePrivateSubs]
allow = _build_thing _trigger_thing
```

# CAVEATS

A method that a subclass overrides is not private, whatever its name says.
Give it a name without the underscore, and document it as the interface
between the class and its subclasses.

A lexical sub cannot be tested from outside its scope.  That is the point: test
the public sub that calls it.

A sub installed through a glob, such as `*_helper = sub { ... }`, is not
seen.

## METHODS

### supported\_parameters

### default\_severity

### default\_themes

### applies\_to

### violates

# AUTHORS

Current Maintainers:

- George S. Baugh <george@troglodyne.net>

# COPYRIGHT AND LICENSE

Copyright (c) 2026 Troglodyne LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
