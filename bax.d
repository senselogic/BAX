/*
    This file is part of the Bax distribution.

    https://github.com/senselogic/BAX

    Copyright (C) 2021 Eric Pelzer (ecstatic.coder@gmail.com)

    Bax is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Bax is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Bax.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import core.stdc.stdlib : exit;
import std.array : replicate;
import std.conv : to;
import std.file : dirEntries, exists, readText, write, SpanMode;
import std.stdio : writeln;
import std.string : endsWith, indexOf, join, lastIndexOf, replace, split, startsWith, strip, stripLeft, stripRight;

// -- TYPES

class CONTEXT
{
    // -- ATTRIBUTES

    long
        TildeSpaceCount,
        BraceSpaceCount,
        UmlautSpaceCount;
}

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void Abort(
    string message,
    Exception exception
    )
{
    PrintError( message );
    PrintError( exception.msg );

    exit( -1 );
}

// ~~

bool IsFolderPath(
    string folder_path
    )
{
    return
        folder_path.endsWith( '/' )
        || folder_path.endsWith( '\\' );
}

// ~~

string GetLogicalPath(
    string path
    )
{
    return path.replace( '\\', '/' );
}

// ~~

void SplitFilePathFilter(
    string file_path_filter,
    ref string folder_path,
    ref string file_name_filter,
    ref SpanMode span_mode
    )
{
    long
        folder_path_character_count;
    string
        file_name;

    folder_path_character_count = file_path_filter.lastIndexOf( '/' ) + 1;

    folder_path = file_path_filter[ 0 .. folder_path_character_count ];
    file_name_filter = file_path_filter[ folder_path_character_count .. $ ];

    if ( folder_path.endsWith( "//" ) )
    {
        folder_path = folder_path[ 0 .. $ - 1 ];

        span_mode = SpanMode.depth;
    }
    else
    {
        span_mode = SpanMode.shallow;
    }
}

// ~~

void WriteText(
    string file_path,
    string file_text
    )
{
    file_text = file_text.stripRight();

    if ( file_text != ""
         && !file_text.endsWith( '\n' ) )
    {
        file_text ~= '\n';
    }

    try
    {
        if ( !file_path.exists()
             || file_path.readText() != file_text )
        {
            writeln( "Writing file : ", file_path );

            file_path.write( file_text );
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't write file : " ~ file_path, exception );
    }
}

// ~~

string ReadText(
    string file_path
    )
{
    string
        file_text;

    writeln( "Reading file : ", file_path );

    try
    {
        file_text = file_path.readText();
    }
    catch ( Exception exception )
    {
        Abort( "Can't read file : " ~ file_path, exception );
    }

    return file_text;
}

// ~~

long GetIndentationSpaceCount(
    string line
    )
{
    long
        indentation_space_count;

    indentation_space_count = 0;

    while ( indentation_space_count < line.length
            && line[ indentation_space_count ] == ' ' )
    {
        ++indentation_space_count;
    }

    return indentation_space_count;
}

// ~~

string[] GetLineArray(
    string text
    )
{
    string[]
        line_array;

    line_array = text.replace( "\r", "" ).replace( "\t", "    " ).split( '\n' );

    foreach ( ref line; line_array )
    {
        line = line.stripRight();
    }

    return line_array;
}

// ~~

void ProcessFile(
    string file_path
    )
{
    char
        character;
    long
        character_index,
        space_count;
    string
        file_text,
        trimmed_line;
    string[]
        line_array;
    CONTEXT
        context;
    CONTEXT[]
        context_array;

    file_text = file_path.ReadText();

    line_array = file_text.GetLineArray();

    context = new CONTEXT();
    context_array = [ context ];

    foreach ( ref line; line_array )
    {
        space_count = line.GetIndentationSpaceCount();
        trimmed_line = line.strip();

        if ( trimmed_line.startsWith( '~' ) )
        {
            context.TildeSpaceCount = 0;
            context.UmlautSpaceCount = 0;
        }

        if ( trimmed_line.startsWith( '¨' ) )
        {
            context.UmlautSpaceCount = 0;
        }

        if ( space_count < 12 )
        {
            context = new CONTEXT();
            context_array = [ context ];
        }
        else
        {
            space_count = 12;

            foreach ( context_; context_array )
            {
                space_count += context_.TildeSpaceCount + context_.UmlautSpaceCount + context_.BraceSpaceCount;
            }

            if ( trimmed_line.startsWith( '}' ) )
            {
                space_count -= context.TildeSpaceCount + context.UmlautSpaceCount + context.BraceSpaceCount;
            }

            line
                = " ".replicate( space_count )
                  ~ trimmed_line;
        }

        if ( trimmed_line.startsWith( '~' ) )
        {
            context.TildeSpaceCount = 2;
        }

        if ( trimmed_line.startsWith( '¨' )
             || trimmed_line.startsWith( "~ ¨" ) )
        {
            context.UmlautSpaceCount = 4;
        }

        for ( character_index = 0;
              character_index < line.length;
              ++character_index )
        {
            character = line[ character_index ];

            if ( character == '\\' )
            {
                ++character_index;
            }
            else if ( character == '{' )
            {
                context = new CONTEXT();
                context_array ~= context;
                context.BraceSpaceCount += 2;
            }
            else if ( character == '}' )
            {
                context_array = context_array[ 0 .. $ - 1 ];
                context = context_array[ $ - 1 ];
            }
        }
    }

    file_path.WriteText( line_array.join( '\n' ) );
}

// ~~

void ProcessFiles(
    string file_path_filter
    )
{
    string
        file_name_filter,
        file_path,
        folder_path;
    SpanMode
        span_mode;

    SplitFilePathFilter( file_path_filter, folder_path, file_name_filter, span_mode );

    foreach ( folder_entry; dirEntries( folder_path, file_name_filter, span_mode ) )
    {
        if ( folder_entry.isFile )
        {
            ProcessFile( folder_entry.name.GetLogicalPath() );
        }
    }
}

// ~~

void main(
    string[] argument_array
    )
{
    string
        input_folder_path,
        option,
        output_folder_path;

    argument_array = argument_array[ 1 .. $ ];

    if ( argument_array.length == 1 )
    {
        ProcessFiles( argument_array[ 0 ].GetLogicalPath() );
    }
    else
    {
        writeln( "Usage :" );
        writeln( "    bax <file filter>" );

        PrintError( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
