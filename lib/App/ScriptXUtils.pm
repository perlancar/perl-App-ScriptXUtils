package App::ScriptXUtils;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict 'subs', 'vars';
use warnings;

use Module::List::Tiny;
use Perinci::Sub::Gen::AccessTable qw(gen_read_table_func);

our %SPEC;

our %argopt_detail = (
    detail => {
        schema => 'bool*',
        cmdline_aliases => {l=>{}},
    },
);

my $res = gen_read_table_func(
    name => 'list_scriptx_plugins',
    summary => 'List locally installed ScriptX plugins',
    table_data => sub {
        my $mods = Module::List::Tiny::list_modules(
            'ScriptX::', {list_modules=>1, recurse=>1});

        my @rows;
        for my $mod (sort keys %$mods) {
            $mod =~ /\AScriptX::(.+)/ or next;
            my $plugin = $1;
            $plugin =~ /Base$/ and next; # by convention, this is base class only
            my $row = {plugin=>$plugin};
            (my $mod_pm = "$mod.pm") =~ s!::!/!g;
            require $mod_pm;
            my $meta = {}; eval { $meta = $mod->meta };
            $row->{summary} = $meta->{summary};
            $row->{dist} = ${"$mod\::DIST"};
            push @rows, $row;
        }
        return {data=>\@rows};
    },
    table_spec => {
        fields => {
            plugin => {
                schema => 'str*',
                pos => 0,
                sortable => 1,
            },
            summary => {
                schema => 'str*',
                pos => 1,
                sortable => 1,
            },
            dist => {
                schema => 'str*',
                pos => 2,
                sortable => 1,
            },
        },
        pk => 'plugin',
    },
);
die "Can't generate function: $res->[0] - $res->[1]" unless $res->[0] == 200;

1;
# ABSTRACT: Collection of CLI utilities for ScriptX

=head1 SYNOPSIS

This distribution provides the following command-line utilities related to
L<ScriptX>:

#INSERT_EXECS_LIST


=head1 SEE ALSO

L<ScriptX>

=cut
