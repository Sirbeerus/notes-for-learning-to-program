<?php

namespace App\Console\Commands;

use Illuminate\Support\Facades\Http;
use Illuminate\Console\Command;

class ZombieChainsNFT extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'zom';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Execute the console command.
     *
     * @return int
     */
    public function handle()
    {
        $response = Http::get('https://api.opencnft.io/1/policy/3c2cfd4f1ad33678039cfd0347cca8df363c710067d739624218abc0/floor_price')->json();

        $floor = $response['floor_price'] / 1000000;
        
        if ( $floor < 25 || $floor > 200 ) {
            $phrase = 'ZombieChainsNFT floor price is: ' . $floor;
        
            $cmd = sprintf(
                'osascript -e \'display notification "%s" with title "Zombie Chains Floor has moved!"\'',
                $phrase
            );
        
            shell_exec($cmd);
        }
    }      
}

