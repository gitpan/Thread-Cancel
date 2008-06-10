use strict;
use warnings;

BEGIN {
    use Config;
    if (! $Config{'useithreads'}) {
        print("1..0 # Skip: Perl not compiled with 'useithreads'\n");
        exit(0);
    }
}

use threads;
use threads::shared;

use Test::More 'tests' => 9;

use_ok('Thread::Cancel', 'SIGILL');

my $thr = threads->create(sub { while (1) { } });
ok($thr, 'Thread created');
ok($thr->is_running(), 'Thread running');
ok(! $thr->is_detached(), 'Thread not detached');
ok(! $thr->cancel(), 'Thread cancelled');
threads->yield();
sleep(1);
ok(! $thr->is_running(), 'Thread not running');
ok($thr->is_detached(), 'Thread detached');

SKIP: {
    skip('Test::More broken WRT threads in 5.8.0', 2) if ($] == 5.008);
    $SIG{'ILL'} = sub {
        is(shift, 'ILL', 'Received cancel signal');
        threads->exit();
    };

    $thr = threads->create(sub { while (1) { } });
    ok(! $thr->cancel(), 'Sent cancel signal');
    threads->yield();
    sleep(1);
}

exit(0);

# EOF
