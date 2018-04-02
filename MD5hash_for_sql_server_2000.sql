/*
ок, нашел ошибку. Алгоритм там правильный, он передран отсюда:
http://www.ldas-sw.ligo.caltech.edu/doc/tcl_docs/html/keytcl.html

Вот патч. Нужно заменить
 
select @buffer = cast( @m as varbinary(55) )
						 + 0x80 +  cast( replicate( 0x00, 64 - 8 - 1 - datalength( @m )  ) as varbinary(64) )
						 + cast( datalength( @m ) * 8 as binary(1) ) + 0x00000000000000
на вот это:
select @buffer = cast( @m as varbinary(55) )
						 + 0x80 +  cast( replicate( 0x00, 64 - 8 - 1 - datalength( @m )  ) as varbinary(64) )
						 + cast( (datalength( @m )*8 & 0xFF) as binary(1) )
						 + cast( (datalength( @m )*8 & 0xFF00)/256 as binary(1) ) 					
						 + 0x0

Проблема в том, что если строка в блоке по 55 символов больше 31 символа длинной, то количество бит в ней больше не помещается в один байт длинны суффикса 512-битного блока для MD5-алгоритма и нужно выставить и второй байт тоже.
*/
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

create function [dbo].[f_get_hash_md5]( @str varchar(max) )
returns binary(16)
as
begin
  declare @a bigint, @b bigint, @c bigint, @d bigint, @x bigint, @t bigint
        , @m varchar(55), @buffer varbinary(64)
        , @hash binary(16), @counter int
  
  select @a = 0x67452301
       , @b = 0xefcdab89
       , @c = 0x98badcfe
       , @d = 0x10325476
	   , @counter=1
  If len(@str)>55
	begin
	While @counter<=len(@str)
	begin

		Set @m=substring( @str, @counter, 55 )

		  select @buffer = cast( @m as varbinary(55) )
						 + 0x80 +  cast( replicate( 0x00, 64 - 8 - 1 - datalength( @m )  ) as varbinary(64) )
						 + cast( datalength( @m ) * 8 as binary(1) ) + 0x00000000000000

		  set @a = dbo.R0( @a, @b, @c, @d, cast( reverse( substring( @buffer, 00 + 1, 4 ) ) as binary(4) ), 128,    0xd76aa478 )
		  set @d = dbo.R0( @d, @a, @b, @c, cast( reverse( substring( @buffer, 04 + 1, 4 ) ) as binary(4) ), 4096,   0xe8c7b756 )
		  set @c = dbo.R0( @c, @d, @a, @b, cast( reverse( substring( @buffer, 08 + 1, 4 ) ) as binary(4) ), 131072, 0x242070db )
		  set @b = dbo.R0( @b, @c, @d, @a, cast( reverse( substring( @buffer, 12 + 1, 4 ) ) as binary(4) ), 4194304,0xc1bdceee )

		  set @a = dbo.R0( @a, @b, @c, @d, cast( reverse( substring( @buffer, 16 + 1, 4 ) ) as binary(4) ), 128,    0xf57c0faf )
		  set @d = dbo.R0( @d, @a, @b, @c, cast( reverse( substring( @buffer, 20 + 1, 4 ) ) as binary(4) ), 4096,   0x4787c62a )
		  set @c = dbo.R0( @c, @d, @a, @b, cast( reverse( substring( @buffer, 24 + 1, 4 ) ) as binary(4) ), 131072, 0xa8304613 )
		  set @b = dbo.R0( @b, @c, @d, @a, cast( reverse( substring( @buffer, 28 + 1, 4 ) ) as binary(4) ), 4194304,0xfd469501 )

		  set @a = dbo.R0( @a, @b, @c, @d, cast( reverse( substring( @buffer, 32 + 1, 4 ) ) as binary(4) ), 128,    0x698098d8 )
		  set @d = dbo.R0( @d, @a, @b, @c, cast( reverse( substring( @buffer, 36 + 1, 4 ) ) as binary(4) ), 4096,   0x8b44f7af )
		  set @c = dbo.R0( @c, @d, @a, @b, cast( reverse( substring( @buffer, 40 + 1, 4 ) ) as binary(4) ), 131072, 0xffff5bb1 )
		  set @b = dbo.R0( @b, @c, @d, @a, cast( reverse( substring( @buffer, 44 + 1, 4 ) ) as binary(4) ), 4194304,0x895cd7be )

		  set @a = dbo.R0( @a, @b, @c, @d, cast( reverse( substring( @buffer, 48 + 1, 4 ) ) as binary(4) ), 128,    0x6b901122 )
		  set @d = dbo.R0( @d, @a, @b, @c, cast( reverse( substring( @buffer, 52 + 1, 4 ) ) as binary(4) ), 4096,   0xfd987193 )
		  set @c = dbo.R0( @c, @d, @a, @b, cast( reverse( substring( @buffer, 56 + 1, 4 ) ) as binary(4) ), 131072, 0xa679438e )
		  set @b = dbo.R0( @b, @c, @d, @a, cast( reverse( substring( @buffer, 60 + 1, 4 ) ) as binary(4) ), 4194304,0x49b40821 )

		  set @a = dbo.R1( @a, @b, @c, @d, cast( reverse( substring( @buffer, 04 + 1, 4 ) ) as binary(4) ), 32,     0xf61e2562 )
		  set @d = dbo.R1( @d, @a, @b, @c, cast( reverse( substring( @buffer, 24 + 1, 4 ) ) as binary(4) ), 512,    0xc040b340 )
		  set @c = dbo.R1( @c, @d, @a, @b, cast( reverse( substring( @buffer, 44 + 1, 4 ) ) as binary(4) ), 16384,  0x265e5a51 )
		  set @b = dbo.R1( @b, @c, @d, @a, cast( reverse( substring( @buffer, 00 + 1, 4 ) ) as binary(4) ), 1048576,0xe9b6c7aa )

		  set @a = dbo.R1( @a, @b, @c, @d, cast( reverse( substring( @buffer, 20 + 1, 4 ) ) as binary(4) ), 32,     0xd62f105d )
		  set @d = dbo.R1( @d, @a, @b, @c, cast( reverse( substring( @buffer, 40 + 1, 4 ) ) as binary(4) ), 512,    0x2441453  )
		  set @c = dbo.R1( @c, @d, @a, @b, cast( reverse( substring( @buffer, 60 + 1, 4 ) ) as binary(4) ), 16384,  0xd8a1e681 )
		  set @b = dbo.R1( @b, @c, @d, @a, cast( reverse( substring( @buffer, 16 + 1, 4 ) ) as binary(4) ), 1048576,0xe7d3fbc8 )

		  set @a = dbo.R1( @a, @b, @c, @d, cast( reverse( substring( @buffer, 36 + 1, 4 ) ) as binary(4) ), 32,     0x21e1cde6 )
		  set @d = dbo.R1( @d, @a, @b, @c, cast( reverse( substring( @buffer, 56 + 1, 4 ) ) as binary(4) ), 512,    0xc33707d6 )
		  set @c = dbo.R1( @c, @d, @a, @b, cast( reverse( substring( @buffer, 12 + 1, 4 ) ) as binary(4) ), 16384,  0xf4d50d87 )
		  set @b = dbo.R1( @b, @c, @d, @a, cast( reverse( substring( @buffer, 32 + 1, 4 ) ) as binary(4) ), 1048576,0x455a14ed )

		  set @a = dbo.R1( @a, @b, @c, @d, cast( reverse( substring( @buffer, 52 + 1, 4 ) ) as binary(4) ), 32,     0xa9e3e905 )
		  set @d = dbo.R1( @d, @a, @b, @c, cast( reverse( substring( @buffer, 08 + 1, 4 ) ) as binary(4) ), 512,    0xfcefa3f8 )
		  set @c = dbo.R1( @c, @d, @a, @b, cast( reverse( substring( @buffer, 28 + 1, 4 ) ) as binary(4) ), 16384,  0x676f02d9 )
		  set @b = dbo.R1( @b, @c, @d, @a, cast( reverse( substring( @buffer, 48 + 1, 4 ) ) as binary(4) ), 1048576,0x8d2a4c8a )


		  set @a = dbo.R2( @a, @b, @c, @d, cast( reverse( substring( @buffer, 20 + 1, 4 ) ) as binary(4) ), 16,     0xfffa3942 )
		  set @d = dbo.R2( @d, @a, @b, @c, cast( reverse( substring( @buffer, 32 + 1, 4 ) ) as binary(4) ), 2048,   0x8771f681 )
		  set @c = dbo.R2( @c, @d, @a, @b, cast( reverse( substring( @buffer, 44 + 1, 4 ) ) as binary(4) ), 65536,  0x6d9d6122 )
		  set @b = dbo.R2( @b, @c, @d, @a, cast( reverse( substring( @buffer, 56 + 1, 4 ) ) as binary(4) ), 8388608,0xfde5380c )

		  set @a = dbo.R2( @a, @b, @c, @d, cast( reverse( substring( @buffer, 04 + 1, 4 ) ) as binary(4) ), 16,     0xa4beea44 )
		  set @d = dbo.R2( @d, @a, @b, @c, cast( reverse( substring( @buffer, 16 + 1, 4 ) ) as binary(4) ), 2048,   0x4bdecfa9 )
		  set @c = dbo.R2( @c, @d, @a, @b, cast( reverse( substring( @buffer, 28 + 1, 4 ) ) as binary(4) ), 65536,  0xf6bb4b60 )
		  set @b = dbo.R2( @b, @c, @d, @a, cast( reverse( substring( @buffer, 40 + 1, 4 ) ) as binary(4) ), 8388608,0xbebfbc70 )

		  set @a = dbo.R2( @a, @b, @c, @d, cast( reverse( substring( @buffer, 52 + 1, 4 ) ) as binary(4) ), 16,     0x289b7ec6 )
		  set @d = dbo.R2( @d, @a, @b, @c, cast( reverse( substring( @buffer, 00 + 1, 4 ) ) as binary(4) ), 2048,   0xeaa127fa )
		  set @c = dbo.R2( @c, @d, @a, @b, cast( reverse( substring( @buffer, 12 + 1, 4 ) ) as binary(4) ), 65536,  0xd4ef3085 )
		  set @b = dbo.R2( @b, @c, @d, @a, cast( reverse( substring( @buffer, 24 + 1, 4 ) ) as binary(4) ), 8388608,0x04881d05 )

		  set @a = dbo.R2( @a, @b, @c, @d, cast( reverse( substring( @buffer, 36 + 1, 4 ) ) as binary(4) ), 16,     0xd9d4d039 )
		  set @d = dbo.R2( @d, @a, @b, @c, cast( reverse( substring( @buffer, 48 + 1, 4 ) ) as binary(4) ), 2048,   0xe6db99e5 )
		  set @c = dbo.R2( @c, @d, @a, @b, cast( reverse( substring( @buffer, 60 + 1, 4 ) ) as binary(4) ), 65536,  0x1fa27cf8 )
		  set @b = dbo.R2( @b, @c, @d, @a, cast( reverse( substring( @buffer, 08 + 1, 4 ) ) as binary(4) ), 8388608,0xc4ac5665 )


		  set @a = dbo.R3( @a, @b, @c, @d, cast( reverse( substring( @buffer, 00 + 1, 4 ) ) as binary(4) ), 64,     0xf4292244 )
		  set @d = dbo.R3( @d, @a, @b, @c, cast( reverse( substring( @buffer, 28 + 1, 4 ) ) as binary(4) ), 1024,   0x432aff97 )
		  set @c = dbo.R3( @c, @d, @a, @b, cast( reverse( substring( @buffer, 56 + 1, 4 ) ) as binary(4) ), 32768,  0xab9423a7 )
		  set @b = dbo.R3( @b, @c, @d, @a, cast( reverse( substring( @buffer, 20 + 1, 4 ) ) as binary(4) ), 2097152,0xfc93a039 )

		  set @a = dbo.R3( @a, @b, @c, @d, cast( reverse( substring( @buffer, 48 + 1, 4 ) ) as binary(4) ), 64,     0x655b59c3 )
		  set @d = dbo.R3( @d, @a, @b, @c, cast( reverse( substring( @buffer, 12 + 1, 4 ) ) as binary(4) ), 1024,   0x8f0ccc92 )
		  set @c = dbo.R3( @c, @d, @a, @b, cast( reverse( substring( @buffer, 40 + 1, 4 ) ) as binary(4) ), 32768,  0xffeff47d )
		  set @b = dbo.R3( @b, @c, @d, @a, cast( reverse( substring( @buffer, 04 + 1, 4 ) ) as binary(4) ), 2097152,0x85845dd1 )

		  set @a = dbo.R3( @a, @b, @c, @d, cast( reverse( substring( @buffer, 32 + 1, 4 ) ) as binary(4) ), 64,     0x6fa87e4f )
		  set @d = dbo.R3( @d, @a, @b, @c, cast( reverse( substring( @buffer, 60 + 1, 4 ) ) as binary(4) ), 1024,   0xfe2ce6e0 )
		  set @c = dbo.R3( @c, @d, @a, @b, cast( reverse( substring( @buffer, 24 + 1, 4 ) ) as binary(4) ), 32768,  0xa3014314 )
		  set @b = dbo.R3( @b, @c, @d, @a, cast( reverse( substring( @buffer, 52 + 1, 4 ) ) as binary(4) ), 2097152,0x4e0811a1 )

		  set @a = dbo.R3( @a, @b, @c, @d, cast( reverse( substring( @buffer, 16 + 1, 4 ) ) as binary(4) ), 64,     0xf7537e82 )
		  set @d = dbo.R3( @d, @a, @b, @c, cast( reverse( substring( @buffer, 44 + 1, 4 ) ) as binary(4) ), 1024,   0xbd3af235 )
		  set @c = dbo.R3( @c, @d, @a, @b, cast( reverse( substring( @buffer, 08 + 1, 4 ) ) as binary(4) ), 32768,  0x2ad7d2bb )
		  set @b = dbo.R3( @b, @c, @d, @a, cast( reverse( substring( @buffer, 36 + 1, 4 ) ) as binary(4) ), 2097152,0xeb86d391 )

		  set @hash = cast( reverse( cast( ( @a + 0x67452301 ) as binary(4) ) )
						  + reverse( cast( ( @b + 0xefcdab89 ) as binary(4) ) )
						  + reverse( cast( ( @c + 0x98badcfe ) as binary(4) ) )
						  + reverse( cast( ( @d + 0x10325476 ) as binary(4) ) )
						  as binary(16) )

		SET @counter=@counter+55

		End

	end
	else
	begin

		SET @m = @str

		select @buffer = cast( @m as varbinary(55) )
						 + 0x80 +  cast( replicate( 0x00, 64 - 8 - 1 - datalength( @m )  ) as varbinary(64) )
						 + cast( datalength( @m ) * 8 as binary(1) ) + 0x00000000000000

		  set @a = dbo.R0( @a, @b, @c, @d, cast( reverse( substring( @buffer, 00 + 1, 4 ) ) as binary(4) ), 128,    0xd76aa478 )
		  set @d = dbo.R0( @d, @a, @b, @c, cast( reverse( substring( @buffer, 04 + 1, 4 ) ) as binary(4) ), 4096,   0xe8c7b756 )
		  set @c = dbo.R0( @c, @d, @a, @b, cast( reverse( substring( @buffer, 08 + 1, 4 ) ) as binary(4) ), 131072, 0x242070db )
		  set @b = dbo.R0( @b, @c, @d, @a, cast( reverse( substring( @buffer, 12 + 1, 4 ) ) as binary(4) ), 4194304,0xc1bdceee )

		  set @a = dbo.R0( @a, @b, @c, @d, cast( reverse( substring( @buffer, 16 + 1, 4 ) ) as binary(4) ), 128,    0xf57c0faf )
		  set @d = dbo.R0( @d, @a, @b, @c, cast( reverse( substring( @buffer, 20 + 1, 4 ) ) as binary(4) ), 4096,   0x4787c62a )
		  set @c = dbo.R0( @c, @d, @a, @b, cast( reverse( substring( @buffer, 24 + 1, 4 ) ) as binary(4) ), 131072, 0xa8304613 )
		  set @b = dbo.R0( @b, @c, @d, @a, cast( reverse( substring( @buffer, 28 + 1, 4 ) ) as binary(4) ), 4194304,0xfd469501 )

		  set @a = dbo.R0( @a, @b, @c, @d, cast( reverse( substring( @buffer, 32 + 1, 4 ) ) as binary(4) ), 128,    0x698098d8 )
		  set @d = dbo.R0( @d, @a, @b, @c, cast( reverse( substring( @buffer, 36 + 1, 4 ) ) as binary(4) ), 4096,   0x8b44f7af )
		  set @c = dbo.R0( @c, @d, @a, @b, cast( reverse( substring( @buffer, 40 + 1, 4 ) ) as binary(4) ), 131072, 0xffff5bb1 )
		  set @b = dbo.R0( @b, @c, @d, @a, cast( reverse( substring( @buffer, 44 + 1, 4 ) ) as binary(4) ), 4194304,0x895cd7be )

		  set @a = dbo.R0( @a, @b, @c, @d, cast( reverse( substring( @buffer, 48 + 1, 4 ) ) as binary(4) ), 128,    0x6b901122 )
		  set @d = dbo.R0( @d, @a, @b, @c, cast( reverse( substring( @buffer, 52 + 1, 4 ) ) as binary(4) ), 4096,   0xfd987193 )
		  set @c = dbo.R0( @c, @d, @a, @b, cast( reverse( substring( @buffer, 56 + 1, 4 ) ) as binary(4) ), 131072, 0xa679438e )
		  set @b = dbo.R0( @b, @c, @d, @a, cast( reverse( substring( @buffer, 60 + 1, 4 ) ) as binary(4) ), 4194304,0x49b40821 )

		  set @a = dbo.R1( @a, @b, @c, @d, cast( reverse( substring( @buffer, 04 + 1, 4 ) ) as binary(4) ), 32,     0xf61e2562 )
		  set @d = dbo.R1( @d, @a, @b, @c, cast( reverse( substring( @buffer, 24 + 1, 4 ) ) as binary(4) ), 512,    0xc040b340 )
		  set @c = dbo.R1( @c, @d, @a, @b, cast( reverse( substring( @buffer, 44 + 1, 4 ) ) as binary(4) ), 16384,  0x265e5a51 )
		  set @b = dbo.R1( @b, @c, @d, @a, cast( reverse( substring( @buffer, 00 + 1, 4 ) ) as binary(4) ), 1048576,0xe9b6c7aa )

		  set @a = dbo.R1( @a, @b, @c, @d, cast( reverse( substring( @buffer, 20 + 1, 4 ) ) as binary(4) ), 32,     0xd62f105d )
		  set @d = dbo.R1( @d, @a, @b, @c, cast( reverse( substring( @buffer, 40 + 1, 4 ) ) as binary(4) ), 512,    0x2441453  )
		  set @c = dbo.R1( @c, @d, @a, @b, cast( reverse( substring( @buffer, 60 + 1, 4 ) ) as binary(4) ), 16384,  0xd8a1e681 )
		  set @b = dbo.R1( @b, @c, @d, @a, cast( reverse( substring( @buffer, 16 + 1, 4 ) ) as binary(4) ), 1048576,0xe7d3fbc8 )

		  set @a = dbo.R1( @a, @b, @c, @d, cast( reverse( substring( @buffer, 36 + 1, 4 ) ) as binary(4) ), 32,     0x21e1cde6 )
		  set @d = dbo.R1( @d, @a, @b, @c, cast( reverse( substring( @buffer, 56 + 1, 4 ) ) as binary(4) ), 512,    0xc33707d6 )
		  set @c = dbo.R1( @c, @d, @a, @b, cast( reverse( substring( @buffer, 12 + 1, 4 ) ) as binary(4) ), 16384,  0xf4d50d87 )
		  set @b = dbo.R1( @b, @c, @d, @a, cast( reverse( substring( @buffer, 32 + 1, 4 ) ) as binary(4) ), 1048576,0x455a14ed )

		  set @a = dbo.R1( @a, @b, @c, @d, cast( reverse( substring( @buffer, 52 + 1, 4 ) ) as binary(4) ), 32,     0xa9e3e905 )
		  set @d = dbo.R1( @d, @a, @b, @c, cast( reverse( substring( @buffer, 08 + 1, 4 ) ) as binary(4) ), 512,    0xfcefa3f8 )
		  set @c = dbo.R1( @c, @d, @a, @b, cast( reverse( substring( @buffer, 28 + 1, 4 ) ) as binary(4) ), 16384,  0x676f02d9 )
		  set @b = dbo.R1( @b, @c, @d, @a, cast( reverse( substring( @buffer, 48 + 1, 4 ) ) as binary(4) ), 1048576,0x8d2a4c8a )


		  set @a = dbo.R2( @a, @b, @c, @d, cast( reverse( substring( @buffer, 20 + 1, 4 ) ) as binary(4) ), 16,     0xfffa3942 )
		  set @d = dbo.R2( @d, @a, @b, @c, cast( reverse( substring( @buffer, 32 + 1, 4 ) ) as binary(4) ), 2048,   0x8771f681 )
		  set @c = dbo.R2( @c, @d, @a, @b, cast( reverse( substring( @buffer, 44 + 1, 4 ) ) as binary(4) ), 65536,  0x6d9d6122 )
		  set @b = dbo.R2( @b, @c, @d, @a, cast( reverse( substring( @buffer, 56 + 1, 4 ) ) as binary(4) ), 8388608,0xfde5380c )

		  set @a = dbo.R2( @a, @b, @c, @d, cast( reverse( substring( @buffer, 04 + 1, 4 ) ) as binary(4) ), 16,     0xa4beea44 )
		  set @d = dbo.R2( @d, @a, @b, @c, cast( reverse( substring( @buffer, 16 + 1, 4 ) ) as binary(4) ), 2048,   0x4bdecfa9 )
		  set @c = dbo.R2( @c, @d, @a, @b, cast( reverse( substring( @buffer, 28 + 1, 4 ) ) as binary(4) ), 65536,  0xf6bb4b60 )
		  set @b = dbo.R2( @b, @c, @d, @a, cast( reverse( substring( @buffer, 40 + 1, 4 ) ) as binary(4) ), 8388608,0xbebfbc70 )

		  set @a = dbo.R2( @a, @b, @c, @d, cast( reverse( substring( @buffer, 52 + 1, 4 ) ) as binary(4) ), 16,     0x289b7ec6 )
		  set @d = dbo.R2( @d, @a, @b, @c, cast( reverse( substring( @buffer, 00 + 1, 4 ) ) as binary(4) ), 2048,   0xeaa127fa )
		  set @c = dbo.R2( @c, @d, @a, @b, cast( reverse( substring( @buffer, 12 + 1, 4 ) ) as binary(4) ), 65536,  0xd4ef3085 )
		  set @b = dbo.R2( @b, @c, @d, @a, cast( reverse( substring( @buffer, 24 + 1, 4 ) ) as binary(4) ), 8388608,0x04881d05 )

		  set @a = dbo.R2( @a, @b, @c, @d, cast( reverse( substring( @buffer, 36 + 1, 4 ) ) as binary(4) ), 16,     0xd9d4d039 )
		  set @d = dbo.R2( @d, @a, @b, @c, cast( reverse( substring( @buffer, 48 + 1, 4 ) ) as binary(4) ), 2048,   0xe6db99e5 )
		  set @c = dbo.R2( @c, @d, @a, @b, cast( reverse( substring( @buffer, 60 + 1, 4 ) ) as binary(4) ), 65536,  0x1fa27cf8 )
		  set @b = dbo.R2( @b, @c, @d, @a, cast( reverse( substring( @buffer, 08 + 1, 4 ) ) as binary(4) ), 8388608,0xc4ac5665 )


		  set @a = dbo.R3( @a, @b, @c, @d, cast( reverse( substring( @buffer, 00 + 1, 4 ) ) as binary(4) ), 64,     0xf4292244 )
		  set @d = dbo.R3( @d, @a, @b, @c, cast( reverse( substring( @buffer, 28 + 1, 4 ) ) as binary(4) ), 1024,   0x432aff97 )
		  set @c = dbo.R3( @c, @d, @a, @b, cast( reverse( substring( @buffer, 56 + 1, 4 ) ) as binary(4) ), 32768,  0xab9423a7 )
		  set @b = dbo.R3( @b, @c, @d, @a, cast( reverse( substring( @buffer, 20 + 1, 4 ) ) as binary(4) ), 2097152,0xfc93a039 )

		  set @a = dbo.R3( @a, @b, @c, @d, cast( reverse( substring( @buffer, 48 + 1, 4 ) ) as binary(4) ), 64,     0x655b59c3 )
		  set @d = dbo.R3( @d, @a, @b, @c, cast( reverse( substring( @buffer, 12 + 1, 4 ) ) as binary(4) ), 1024,   0x8f0ccc92 )
		  set @c = dbo.R3( @c, @d, @a, @b, cast( reverse( substring( @buffer, 40 + 1, 4 ) ) as binary(4) ), 32768,  0xffeff47d )
		  set @b = dbo.R3( @b, @c, @d, @a, cast( reverse( substring( @buffer, 04 + 1, 4 ) ) as binary(4) ), 2097152,0x85845dd1 )

		  set @a = dbo.R3( @a, @b, @c, @d, cast( reverse( substring( @buffer, 32 + 1, 4 ) ) as binary(4) ), 64,     0x6fa87e4f )
		  set @d = dbo.R3( @d, @a, @b, @c, cast( reverse( substring( @buffer, 60 + 1, 4 ) ) as binary(4) ), 1024,   0xfe2ce6e0 )
		  set @c = dbo.R3( @c, @d, @a, @b, cast( reverse( substring( @buffer, 24 + 1, 4 ) ) as binary(4) ), 32768,  0xa3014314 )
		  set @b = dbo.R3( @b, @c, @d, @a, cast( reverse( substring( @buffer, 52 + 1, 4 ) ) as binary(4) ), 2097152,0x4e0811a1 )

		  set @a = dbo.R3( @a, @b, @c, @d, cast( reverse( substring( @buffer, 16 + 1, 4 ) ) as binary(4) ), 64,     0xf7537e82 )
		  set @d = dbo.R3( @d, @a, @b, @c, cast( reverse( substring( @buffer, 44 + 1, 4 ) ) as binary(4) ), 1024,   0xbd3af235 )
		  set @c = dbo.R3( @c, @d, @a, @b, cast( reverse( substring( @buffer, 08 + 1, 4 ) ) as binary(4) ), 32768,  0x2ad7d2bb )
		  set @b = dbo.R3( @b, @c, @d, @a, cast( reverse( substring( @buffer, 36 + 1, 4 ) ) as binary(4) ), 2097152,0xeb86d391 )

		  set @hash = cast( reverse( cast( ( @a + 0x67452301 ) as binary(4) ) )
						  + reverse( cast( ( @b + 0xefcdab89 ) as binary(4) ) )
						  + reverse( cast( ( @c + 0x98badcfe ) as binary(4) ) )
						  + reverse( cast( ( @d + 0x10325476 ) as binary(4) ) )
						  as binary(16) )

	end
  
  return @hash
end
