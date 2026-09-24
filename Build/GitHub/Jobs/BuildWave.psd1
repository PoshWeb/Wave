@{
    "runs-on" = "ubuntu-latest"    
    if = '${{ success() }}'
    steps = @(
        @{
            name = 'Check out repository'
            uses = 'actions/checkout@main'
        }
        'RunEZOut',
        @{
            name = 'Wave Action'
            if   = '${{github.ref_name != ''main''}}'
            uses = './'
            id = 'WaveAction'                       
        }
    )
}