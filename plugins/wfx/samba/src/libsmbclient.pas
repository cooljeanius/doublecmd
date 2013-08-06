unit libsmbclient;

{$mode delphi}

interface

uses
  Classes, SysUtils,
  Unix, BaseUnix, UnixType;

const
  SMBC_WORKGROUP      = 1;
  SMBC_SERVER         = 2;
  SMBC_FILE_SHARE     = 3;
  SMBC_PRINTER_SHARE  = 4;
  SMBC_COMMS_SHARE    = 5;
  SMBC_IPC_SHARE      = 6;
  SMBC_DIR            = 7;
  SMBC_FILE           = 8;
  SMBC_LINK           = 9;

const
  SMBC_DOS_MODE_READONLY       = $01;
  SMBC_DOS_MODE_HIDDEN         = $02;
  SMBC_DOS_MODE_SYSTEM         = $04;
  SMBC_DOS_MODE_VOLUME_ID      = $08;
  SMBC_DOS_MODE_DIRECTORY      = $10;
  SMBC_DOS_MODE_ARCHIVE        = $20;

type
  (**@ingroup structure
   * Structure that represents a directory entry.
   *
   *)
  psmbc_dirent = ^smbc_dirent;
  smbc_dirent = record
  	(** Type of entity.
  	    SMBC_WORKGROUP=1,
  	    SMBC_SERVER=2,
  	    SMBC_FILE_SHARE=3,
  	    SMBC_PRINTER_SHARE=4,
  	    SMBC_COMMS_SHARE=5,
  	    SMBC_IPC_SHARE=6,
  	    SMBC_DIR=7,
  	    SMBC_FILE=8,
  	    SMBC_LINK=9,*)
  	smbc_type: LongWord;

  	(** Length of this smbc_dirent in bytes
  	 *)
  	dirlen: LongWord;
  	(** The length of the comment string in bytes (does not include
  	 *  null terminator)
  	 *)
  	commentlen: LongWord;
  	(** Points to the null terminated comment string
  	 *)
  	comment: PAnsiChar;
  	(** The length of the name string in bytes (does not include
  	 *  null terminator)
  	 *)
  	namelen: LongWord;
  	(** Points to the null terminated name string
  	 *)
  	name: array[0..0] of AnsiChar;
  end;

  smbc_get_auth_data_fn = procedure(server, share: PAnsiChar;
                                    wg: PAnsiChar; wglen: LongInt;
                                    un: PAnsiChar; unlen: LongInt;
                                    pw: PAnsiChar; pwlen: LongInt); cdecl;

  smbc_init_fn = function (fn: smbc_get_auth_data_fn; debug: LongInt): LongInt; cdecl;
  smbc_open_fn = function(furl: PAnsiChar; flags: LongInt; mode: mode_t): LongInt; cdecl;
  smbc_read_fn = function(fd: LongInt; buf: Pointer; bufsize: size_t): ssize_t; cdecl;
  smbc_write_fn = function(fd: LongInt; buf: Pointer; bufsize: size_t): ssize_t; cdecl;
  smbc_lseek_fn = function(fd: LongInt; offset: off_t; whence: LongInt): off_t; cdecl;
  smbc_close_fn = function(fd: LongInt): LongInt; cdecl;
  smbc_unlink_fn = function(furl: PAnsiChar): LongInt; cdecl;
  smbc_rename_fn = function(ourl: PAnsiChar; nurl: PAnsiChar): LongInt; cdecl;
  smbc_opendir_fn = function(durl: PAnsiChar): LongInt; cdecl;
  smbc_closedir_fn = function(dh: LongInt): LongInt; cdecl;
  smbc_readdir_fn = function(dh: LongInt): psmbc_dirent; cdecl;
  smbc_mkdir_fn = function(durl: PAnsiChar; mode: mode_t): LongInt; cdecl;
  smbc_rmdir_fn = function(durl: PAnsiChar): LongInt; cdecl;
  smbc_stat_fn = function(url: PAnsiChar; st: PStat): LongInt; cdecl;
  smbc_getxattr_fn = function(url, name: PAnsiChar; value: Pointer; size: size_t): LongInt; cdecl;
  smbc_setxattr_fn = function(url, name: PAnsiChar; value: Pointer; size: size_t; flags: LongInt): LongInt; cdecl;
  smbc_utimes_fn = function(url: PAnsiChar; tbuf: ptimeval): LongInt; cdecl;

var
   smbc_init: smbc_init_fn;
   smbc_open: smbc_open_fn;
   smbc_read: smbc_read_fn;
   smbc_write: smbc_write_fn;
   smbc_lseek: smbc_lseek_fn;
   smbc_close: smbc_close_fn;
   smbc_unlink: smbc_unlink_fn;
   smbc_rename: smbc_rename_fn;
   smbc_opendir: smbc_opendir_fn;
   smbc_closedir: smbc_closedir_fn;
   smbc_readdir: smbc_readdir_fn;
   smbc_mkdir: smbc_mkdir_fn;
   smbc_rmdir: smbc_rmdir_fn;
   smbc_stat: smbc_stat_fn;
   smbc_getxattr: smbc_getxattr_fn;
   smbc_setxattr: smbc_setxattr_fn;
   smbc_utimes: smbc_utimes_fn;

function LoadSambaLibrary: Boolean;

implementation

uses dynlibs;

var
  hSamba: TLibHandle = 0;

function LoadSambaLibrary: Boolean;
begin
  if (hSamba = 0) then
  begin
    hSamba:= LoadLibrary('libsmbclient.so.0');
    if (hSamba <> 0) then
    begin
      @smbc_init:= GetProcAddress(hSamba, 'smbc_init');
      @smbc_opendir:= GetProcAddress(hSamba, 'smbc_opendir');
      @smbc_readdir:= GetProcAddress(hSamba, 'smbc_readdir');
      @smbc_closedir:= GetProcAddress(hSamba, 'smbc_closedir');
      @smbc_mkdir:= GetProcAddress(hSamba, 'smbc_mkdir');
      @smbc_rmdir:= GetProcAddress(hSamba, 'smbc_rmdir');
      @smbc_open:= GetProcAddress(hSamba, 'smbc_open');
      @smbc_read:= GetProcAddress(hSamba, 'smbc_read');
      @smbc_write:= GetProcAddress(hSamba, 'smbc_write');
      @smbc_lseek:= GetProcAddress(hSamba, 'smbc_lseek');
      @smbc_close:= GetProcAddress(hSamba, 'smbc_close');
      @smbc_unlink:= GetProcAddress(hSamba, 'smbc_unlink');
      @smbc_rename:= GetProcAddress(hSamba, 'smbc_rename');
      @smbc_stat:= GetProcAddress(hSamba, 'smbc_stat');
      @smbc_getxattr:= GetProcAddress(hSamba, 'smbc_getxattr');
      @smbc_setxattr:= GetProcAddress(hSamba, 'smbc_setxattr');
      @smbc_utimes:= GetProcAddress(hSamba, 'smbc_utimes');
    end;
  end;
  Result:= (hSamba <> 0);
end;

end.

