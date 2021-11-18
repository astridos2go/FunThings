Param(
    [Parameter(Position=1)]
    [Alias('Gay')]
    [boolean]$Rainbow = $true,

    [Parameter(Position=2)]
    [boolean]$SetAliases = $true,

    [Parameter(Position=3)]
    [boolean]$HideFromPSReadLine = $true
)

if ($Rainbow) {
    try {
        Import-Module lolcat
        Set-Alias Write-Out Out-Rainbow
    }
    catch {
        Write-Warning "Module: 'lolcat' is not present on this system. You can install lolcat by running 'Install-Module lolcat -Scope CurrentUser'!"
        SetAlias Write-Out Write-Output
    }
}

if ($SetAliases) {
    Set-Alias roll New-DiceRoll
    Set-Alias magic8ball New-PremadeAnswer
    Set-Alias coinflip New-CoinFlip
}


if ($HideFromPSReadLine && (Get-Module -ListAvailable PSReadLine)) {
    # Ignore magic8ball commands
    $HistoryHandler = {
        [string]$line = $args
        if ($line -like "*magic8ball*") {
            $false
        }

        elseif ($line -like "*coinflip*") {
            $false
        }

        elseif ($line -like "*roll*") {
            $false
        }

        else {
            $true
        }
    }

    Set-PSReadLineOption -AddToHistoryHandler $HistoryHandler   # Use custom history handler
}

# Flips a coin a number of times (default: 1)
function New-CoinFlip
{
    <# 
        .SYNOPSIS
            Flips a coin, and returns results.
        .DESCRIPTION
            Gets a random number between 1 and 10000 and returns 'Heads', or 'Tails' depending on if the number is even or odd, and whether even or odd has been designated as the truth value.
        .PARAMETER Times
            The number of times to flip a coin
        .PARAMETER Guess
            The user's guess for what the result will be
    #>
    
    Param(
        [int]
        $Times = 1,
        
        [Parameter(Position=1)]
        [string]
        $Guess=""
    )

    $guess = (Get-Culture).TextInfo.ToTitleCase($guess.ToLower())
    
    function _flip
    {
        # Get a random number
        [int]$random_number = Get-Random -Minimum 1 -Maximum 10001
        # Get 0 or 1, to determine true or false
        [int]$even_or_odd = Get-Random -Minimum 0 -Maximum 2
        
        $result = $false
        
        if ($random_number % 2 -eq $even_or_odd) {
            $result = $True
        }

        $result
    }
    
    # Case for multiple flips
    if($times -gt 1) {
        [int]$head_count = 0    # Count the number of 'Heads' results
        [int]$tail_count = 0    # Count the number of 'Tails' results

        # Loop
        ForEach ($i in 1..$times) {
            # Count each result, respectively
            if(_flip) {
                $head_count++
            }
            else {
                $tail_count++
            }
        }

        $result = "Heads"  # Assume that 'Heads' wins
        
        # Check that assumption
        if ($tail_count -gt $head_count) {
            $result = "Tails"  # 'Tails' wins
        }

        if ($guess -ne "") {
            if ($guess -eq $result) {$user_result = "right!"} else {$user_result = "wrong."}
            $result_message = "You guessed '$guess'... `nYou were $user_result $result wins!"
        }
        else {$result_message = "$result wins!"}
        
        # Print the output
        Write-Out "$result_message`n==============`nHeads: $head_count wins`nTails: $tail_count wins`n"
    }

    # Singular flip
    else {
        $result = "tails"
        if (_flip) {
            $result = "heads"
        }
        Write-Out "It was $result!"
    }

}

# Rolls a dice (default: d6) a number of times (default: 1)
function New-DiceRoll
{
    <# 
        .SYNOPSIS
            Rolls a die, and returns results.
        .DESCRIPTION
            Generates a random number between 1 and maximum (default: 6), specified number of times (default: 1) and adds the result if flagged
        .PARAMETER Number
            The number of die to roll
        .PARAMETER Maximum
            The number of sides on the die (or the maximum number possible for Get-Random)
        .PARAMETER SeparateResults
            Whether the function should show the individual rolls or aggregate them. Defaults to false.
        .PARAMETER HideAverage
            Whether the average roll should be hidden. Defaults to false.
    #>
    Param(
        [Parameter(Position=1)]
        [Alias('times')]
        [int]
        $Number = 1,    
    
        [Parameter(Position=2)]
        [Alias('d', 'sides', 'size')]
        [int]
        $Maximum = 6,

        [Parameter()]
        [Alias('separate', 'noAdd')]
        [switch]
        $SeparateResults = $false,

        [Parameter()]
        [Alias('average', 'avg')]
        [switch]
        $HideAverage = $false
    )

    # Helper function
    function _roll {
        # Get a random number between 1 and size (add 1 for inclusive)
        Get-Random -Minimum 1 -Maximum ($Maximum + 1)
    }

    [int]$result = 0

    # If it is called multiple times...
    if ($Number -gt 1) {
        Write-Out "Rolling ${Number} d${Maximum}s!`n====================="
        
        ForEach($i in 1..$Number) {
            if($SeparateResults) {
                $result = _roll
                Write-Out "Dice ${i}: $result"
            } else {
                $result += _roll
            }
        }

        if (-not $SeparateResults) {
            Write-Out "Total: $result"
        }

        if (-not $HideAverage) {
            [float]$Average = $result/$Number 
            Write-Out "Average: $average"
        }
    }

    # If it is called once
    else {
        $result = _roll
        Write-Out "Rolled a d$Maximum, got a $result!"
    }
}

function New-PremadeAnswer
{
    Param(
        [Parameter(ValueFromRemainingArguments)]
        $query
    )

    # All possible Magic 8 Ball responses
    [array]$responses = @("It is certain.",
                          "It is decidedly so.",
                          "Without a doubt.",
                          "Yes definitely.",
                          "You may rely on it.",
                          "As I see it, yes.",
                          "Most likely.",
                          "Outlook good.",
                          "Yes.",
                          "Signs point to yes.",
                          "Reply hazy, try again.",
                          "Ask again later.",
                          "Better not tell you now.",
                          "Cannot predict now.",
                          "Concentrate and ask again.",
                          "Don't count on it.",
                          "My reply is no.",
                          "My sources say no.",
                          "Outlook not so good.",
                          "Very doubtful.")

    # Randomize the order
    $responses = $responses | Sort-Object {Get-Random}

    # Pick a random value
    [int]$idx = Get-Random -Minimum 0 -Maximum $responses.Length

    # Get the reply
    $reply = $responses[$idx]

    # Reply
    Write-Out "$reply"
}

