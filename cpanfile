requires 'HTTP::Request';
requires 'JSON', '2';
requires 'Module::Load';
requires 'Time::HiRes';
requires 'URI';
requires 'WWW::Mechanize';
requires 'Web::Query';
requires 'parent';
requires 'perl', '5.008001';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};

on test => sub {
    requires 'Test::More', '0.98';
};
