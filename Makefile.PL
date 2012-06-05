
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Provides an OO wrapper for After the Deadline grammar and spelling service.",
  "AUTHOR" => "David L. Day <dday376\@gmail.com>",
  "BUILD_REQUIRES" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "Test::Exception" => 0,
    "Test::More" => "0.88"
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Lingua-AtD",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Lingua::AtD",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Class::Std" => 0,
    "Exception::Class" => 0,
    "LWP::UserAgent" => 0,
    "URI" => 0,
    "XML::LibXML" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "1.121570",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



