package Perl::Critic::Policy::Subroutines::ProhibitUnderscorePrivateSubs;

# ABSTRACT: Make a private sub lexical, rather than private by a leading underscore.

use strict;
use warnings FATAL => 'all';

use 5.014;

use re '/aa';

use Readonly;

use Perl::Critic::Utils qw{ :severities };
use parent              qw{Perl::Critic::Policy};

=head1 Perl::Critic::Policy::Subroutines::ProhibitUnderscorePrivateSubs

A leading underscore says that a sub is private, and nothing enforces it.  Any
code can call C<Some::Module::_helper>, a subclass can override it without
knowing, and a test that calls it pins the implementation instead of the
interface.  A lexical sub is private in fact: nothing outside its scope can
name it.

    sub _helper { ... }                  # reported
    _helper(@args);

    my sub helper { ... }                # perl 5.26 and later
    helper(@args);

    my $helper = sub { ... };            # any perl
    $helper->(@args);
    $self->$helper(@args);               # called as a method

=head2 PROHIBITED

    sub _helper { ... }
    sub _helper;                         # a forward declaration
    sub Some::Module::_helper { ... }    # the last part of the name counts
    our sub _helper { ... }              # our is a package sub

=head2 ALLOWED

    my sub helper { ... }
    state sub helper { ... }
    my $helper = sub { ... };
    sub helper { ... }                   # public, and named so
    sub _build_thing { ... }             # when allow names it, see PARAMETERS

=head1 PARAMETERS

C<allow> is a list of names, separated by whitespace, that the policy leaves
alone.  Use it for a name that another module requires to be a package sub,
such as a builder that an object system looks up by name:

    [Subroutines::ProhibitUnderscorePrivateSubs]
    allow = _build_thing _trigger_thing

=head1 CAVEATS

A method that a subclass overrides is not private, whatever its name says.
Give it a name without the underscore, and document it as the interface
between the class and its subclasses.

A lexical sub cannot be tested from outside its scope.  That is the point: test
the public sub that calls it.

A sub installed through a glob, such as C<*_helper = sub { ... }>, is not
seen.

=cut

Readonly::Scalar my $DESC => q{Private sub named with a leading underscore};
Readonly::Scalar my $EXPL => q{Make it a lexical sub: "my sub" or "my $name = sub"};

# The kinds of declaration that are scoped to a block, as PPI::Statement::Sub
# reports them.
Readonly::Hash my %LEXICAL => map { $_ => 1 } qw{ my state };

=head2 METHODS

=head3 supported_parameters

=head3 default_severity

=head3 default_themes

=head3 applies_to

=cut

sub supported_parameters {
    return (
        {
            name           => 'allow',
            description    => 'Names of subs that another module requires to be package subs.',
            default_string => q{},
            behavior       => 'string list',
        },
    );
}
sub default_severity { return $SEVERITY_MEDIUM }
sub default_themes   { return qw{ maintenance } }
sub applies_to       { return 'PPI::Statement::Sub' }

=head3 violates

=cut

sub violates {
    my ( $self, $elem, undef ) = @_;

    my $type = $elem->type // q{};
    return if $LEXICAL{$type} || $elem->reserved;

    my $name = $elem->name // return;
    my ($last) = $name =~ m/(\w+)\z/sx;
    return unless defined $last && substr( $last, 0, 1 ) eq '_';
    return if $self->{_allow}{$last};

    return $self->violation( $DESC, $EXPL, $elem );
}

1;
