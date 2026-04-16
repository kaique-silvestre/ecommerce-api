# ─────────────────────────────────────────────────────────
#  ECommerceAPI — Smoke Test  (PS 5.1 e PS 7+ compatível)
# ─────────────────────────────────────────────────────────
$BaseUrl   = "https://localhost:7005"
$AdminEmail    = "admin@ecommerce.local"
$AdminPassword = "Admin@123456"
$testEmail = "user_$([DateTime]::UtcNow.Ticks)@t.com"
$testPass  = "Senha@123"

# ── Ignorar certificado TLS self-signed ──────────────────
$psVersion = $PSVersionTable.PSVersion.Major
if ($psVersion -lt 7) {
    Add-Type @"
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
public class TrustAll {
    public static void Ignore() {
        ServicePointManager.ServerCertificateValidationCallback =
            (object s, X509Certificate c, X509Chain ch, SslPolicyErrors e) => true;
    }
}
"@
    [TrustAll]::Ignore()
    $SkipCert = @{}
} else {
    $SkipCert = @{ SkipCertificateCheck = $true }
}

# ── Contadores ────────────────────────────────────────────
$pass  = 0
$fail  = 0

# ── Helper ───────────────────────────────────────────────
function Assert-Status {
    param(
        [string]   $Name,
        [int[]]    $Expected,
        [scriptblock] $Block
    )
    try {
        $result = & $Block
        $actual = $result.StatusCode
    } catch {
        $actual = $null
        if ($_.Exception.Response -ne $null) {
            $actual = [int]$_.Exception.Response.StatusCode
        }
        if ($actual -eq $null -and $_.Exception.Response.StatusCode.value__ -ne $null) {
            $actual = [int]$_.Exception.Response.StatusCode.value__
        }
    }

    if ($Expected -contains $actual) {
        Write-Host "  [PASS] $Name  (esperado $($Expected -join '/'), recebeu $actual)" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "  [FAIL] $Name  (esperado $($Expected -join '/'), recebeu $actual)" -ForegroundColor Red
        $script:fail++
    }
}

# ── Variáveis capturadas durante os testes ───────────────
$adminToken    = $null
$customerToken = $null

# ═════════════════════════════════════════════════════════
Write-Host "`n=== ECommerceAPI Smoke Test ===" -ForegroundColor Cyan
Write-Host "Base URL : $BaseUrl"
Write-Host "Email temporario: $testEmail`n"

# 1. Register — novo usuário válido → 200
Assert-Status "1. Register usuario novo" @(200) {
    Invoke-WebRequest @SkipCert -Method POST -Uri "$BaseUrl/api/auth/register" `
        -ContentType "application/json" `
        -Body (ConvertTo-Json @{ name="Smoke User"; email=$testEmail; password=$testPass })
}

# 2. Register — email duplicado → 409
Assert-Status "2. Register email duplicado" @(409) {
    Invoke-WebRequest @SkipCert -Method POST -Uri "$BaseUrl/api/auth/register" `
        -ContentType "application/json" `
        -Body (ConvertTo-Json @{ name="Outro"; email=$testEmail; password=$testPass })
}

# 3. Register — senha curta (<8 chars) → 400
Assert-Status "3. Register senha curta" @(400) {
    Invoke-WebRequest @SkipCert -Method POST -Uri "$BaseUrl/api/auth/register" `
        -ContentType "application/json" `
        -Body (ConvertTo-Json @{ name="X"; email="short_$([DateTime]::UtcNow.Ticks)@t.com"; password="1234" })
}

# 4. Login — senha errada → 401
Assert-Status "4. Login senha errada" @(401) {
    Invoke-WebRequest @SkipCert -Method POST -Uri "$BaseUrl/api/auth/login" `
        -ContentType "application/json" `
        -Body (ConvertTo-Json @{ email=$testEmail; password="SenhaErrada!" })
}

# 5. Login — admin seed → 200, capturar token
try {
    $r = Invoke-WebRequest @SkipCert -Method POST -Uri "$BaseUrl/api/auth/login" `
        -ContentType "application/json" `
        -Body (ConvertTo-Json @{ email=$AdminEmail; password=$AdminPassword })
    $adminToken = ($r.Content | ConvertFrom-Json).accessToken
    if ($r.StatusCode -eq 200 -and $adminToken) {
        Write-Host "  [PASS] 5. Login admin seed  (esperado 200, recebeu 200)" -ForegroundColor Green
        $pass++
    } else {
        Write-Host "  [FAIL] 5. Login admin seed  (token nao obtido)" -ForegroundColor Red
        $fail++
    }
} catch {
    Write-Host "  [FAIL] 5. Login admin seed  (excecao: $_)" -ForegroundColor Red
    $fail++
}

# 6. Login — customer do cenário 1 → 200, capturar token
try {
    $r = Invoke-WebRequest @SkipCert -Method POST -Uri "$BaseUrl/api/auth/login" `
        -ContentType "application/json" `
        -Body (ConvertTo-Json @{ email=$testEmail; password=$testPass })
    $customerToken = ($r.Content | ConvertFrom-Json).accessToken
    if ($r.StatusCode -eq 200 -and $customerToken) {
        Write-Host "  [PASS] 6. Login customer  (esperado 200, recebeu 200)" -ForegroundColor Green
        $pass++
    } else {
        Write-Host "  [FAIL] 6. Login customer  (token nao obtido)" -ForegroundColor Red
        $fail++
    }
} catch {
    Write-Host "  [FAIL] 6. Login customer  (excecao: $_)" -ForegroundColor Red
    $fail++
}

# 7. GET /api/products — sem token → 200 (publico)
Assert-Status "7. GET /api/products sem token" @(200) {
    Invoke-WebRequest @SkipCert -Method GET -Uri "$BaseUrl/api/products"
}

# 8. DELETE /api/products/1 — sem token → 401
Assert-Status "8. DELETE sem token" @(401) {
    Invoke-WebRequest @SkipCert -Method DELETE -Uri "$BaseUrl/api/products/1"
}

# 9. DELETE /api/products/1 — token Customer → 403
Assert-Status "9. DELETE com token Customer" @(403) {
    Invoke-WebRequest @SkipCert -Method DELETE -Uri "$BaseUrl/api/products/1" `
        -Headers @{ Authorization = "Bearer $customerToken" }
}

# 10. DELETE /api/products/999999 — token Admin → 404
Assert-Status "10. DELETE id inexistente com Admin" @(404) {
    Invoke-WebRequest @SkipCert -Method DELETE -Uri "$BaseUrl/api/products/999999" `
        -Headers @{ Authorization = "Bearer $adminToken" }
}

# 11. POST /api/products — sem token → 401
Assert-Status "11. POST sem token" @(401) {
    Invoke-WebRequest @SkipCert -Method POST -Uri "$BaseUrl/api/products" `
        -ContentType "application/json" `
        -Body (ConvertTo-Json @{ name="X"; description="y"; price=1.0; stock=1 })
}

# 12. POST /api/products — token Admin, body válido → 200 ou 201
Assert-Status "12. POST com Admin (criar produto)" @(200, 201) {
    Invoke-WebRequest @SkipCert -Method POST -Uri "$BaseUrl/api/products" `
        -ContentType "application/json" `
        -Headers @{ Authorization = "Bearer $adminToken" } `
        -Body (ConvertTo-Json @{ name="Produto Smoke"; description="teste"; price=9.9; stock=10 })
}

# ═════════════════════════════════════════════════════════
Write-Host "`n=== RESUMO ===" -ForegroundColor Cyan
Write-Host "  PASS: $pass" -ForegroundColor Green
Write-Host "  FAIL: $fail" -ForegroundColor $(if ($fail -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($fail -gt 0) { exit 1 } else { exit 0 }
