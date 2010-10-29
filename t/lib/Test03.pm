package Test02;

use Moose;
use MooseX::Exception qw(TryCatch);

try {
    die('hase');
};

print "------------------------\n";

try {
    die('hase2');
}
where "X" => catch {
    print('Caught X');
}
catch {
    print('Caught Anything');
}
finally {
    print('Run finally');
};

#use Moose;
#use MooseX::Exception qw(trycatch);
#__PACKAGE__->meta->make_immutable;
1;