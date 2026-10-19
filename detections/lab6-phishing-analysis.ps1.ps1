# Lab 6: Phishing email triage
# Pulls the sender details, email authentication results, and real link
# destinations out of a raw .eml file, and defangs the links so they can't be clicked.
# Usage: change the path below to the .eml you are analyzing.

$eml = Get-Content "$HOME\Desktop\lab6-sample-phish.eml" -Raw

Write-Host "`n=== WHO SENT IT ===" -ForegroundColor Cyan
# From, Reply-To, and Return-Path should normally share a domain. A mismatch is a red flag.
$eml -split "`r?`n" | Where-Object { $_ -match '^(From|Reply-To|Return-Path|Subject):' }

Write-Host "`n=== ID CHECKS ===" -ForegroundColor Cyan
# SPF = is the server allowed to send for this domain? DKIM = is it signed? DMARC = policy result.
[regex]::Matches($eml, '(spf|dkim|dmarc)=\w+') | ForEach-Object { $_.Value }

Write-Host "`n=== REAL LINK DESTINATIONS ===" -ForegroundColor Cyan
# The href is where a link really goes, not the text shown in the email. Output is defanged (hxxp, [.]).
[regex]::Matches($eml, 'href="([^"]+)"') | ForEach-Object { $_.Groups[1].Value -replace 'http','hxxp' -replace '\.','[.]' }

# Tested output on the Lab 6 sample:
# Return-Path: <bounce-7731@mass-mailer-04.example>
# From: "Helpdesk IT Support" <it-support@helpdesk-support.example>
# Reply-To: <account-verify@quick-reset-desk.example>
# spf=fail / dkim=none / dmarc=fail
# hxxp://helpdesk-local[.]quick-reset-desk[.]example/verify?user=akim
