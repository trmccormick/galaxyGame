PROGRAM Paths( input, output );
{****************************************************************************
   Programmer                       :  Tracy Mccormick
   Date                             :  November 17, 1995
   Input (keyboard)                 :  User enter the number of nodes in the
                                       graph and then lables the nodes and
                                       answers the questions about the
                                       adjacency of the nodes to each other.
   Purpose                          :  Find the shortest distance from the
                                       base node to every other nodes in the
                                       matrix.
   Output (screen, file or printer) :  you can display the adjacency matrix
                                       and the shortest distance between the
                                       base node and every other node. you
                                       can direct the output to the screen,
                                       file or printer.
****************************************************************************}
Uses CRT, MyUnit, Utility, printer;

Const
  maxqueue = 10;
  Stringlimit = 4;{Used to set length of a String}
  maxvertex = 15;
type
  Tstring = String[Stringlimit];
  vertex = 1..maxvertex;
  counter = 0..maxvertex;
  adjacency = record
   info : 0..1;
   adjacency_set : boolean
  end;
  adjacencytable = array[vertex, vertex] of adjacency;
  graph = record
   Name : array[vertex] of Tstring;
   pred, distance : array[vertex] of integer;
   Visited : array[vertex] of boolean;
   size: counter;
   A : adjacencytable
  end;
  queuepointer =  ^queuenode;
  queuenode    =  record
           entry: integer;
           nextnode:   queuepointer {link to next node in list}
          end;
  queue = record
           Count : Integer;
           front,
           rear:   queuepointer
          end;
Var
 Matrix : graph;
 outfile : text;
 Screen_row : integer;
 Choice : Char;

procedure CreateQueue(var Q: queue);
{
Pre:  None.
Post: The linked queue Q has been created and is initialized to be empty.
}
begin
  Q.Count := 0;
  Q.front := nil;
  Q.rear  := nil
end;                    {procedure CreateQueue}

function QueueEmpty(var Q: queue): Boolean;
{
Pre:  The queue Q has been created.
Post: The function returns true if the queue Q is empty, false otherwise.
}
begin
  QueueEmpty := (Q.count = 0)
end;                    {function QueueEmpty}

function QueueFull(var Q: queue): Boolean;
{
Pre:   The queue Q has been created.
Post: The function returns true if the queue Q is full, false otherwise.
}
begin
  QueueFull := (Q.count = maxqueue)
end;                    {function QueueFull}

procedure Append(var x: queuepointer;  var Q: queue);
{
Pre:   The queue Q has been created and is not full.
Post: The entry x has been stored in the queue as its last entry.
Uses: QueueFull, Error.
}

begin                   {procedure Append}
  with  Q  do
    if QueueFull(Q) then
      Error('Cannot append an entry to a full queue.')
    else
     begin
      if QueueEmpty(Q) then
       Begin{If}
        Front := x;
        Rear := x;
       End{IF}
      Else
       Begin
        rear^.nextnode := x;
        rear := rear^.nextnode;
       end;
      count := count + 1;
      Rear^.Nextnode := NIL;
     end
end;                    {procedure Append}

procedure Serve(var x: queuepointer; var Q: queue);
{
Pre:  The queue Q has been created and is not empty.
Post: The first entry in the queue has been removed.
Uses: QueueEmpty, Error.
}
begin                   {procedure Serve}
  with  Q  do
    if QueueEmpty(Q) then
      Error('Cannot serve from an empty queue.')
    else
     IF Q.Front <> NIL Then
      begin
       count := count - 1;
       IF Count = 0 then
        Begin{IF}
         X := front;
         Createqueue(Q);
        End{IF}
       ELSE
        Begin{Else}
         X := front;
         front := front^.nextnode;
        End;{Else}
      end;{ELSE}
end;                    {procedure Serve}

Procedure Setup_Matrix(var Matrix : graph);
var row, col, temp, temp_2 : integer;
var temp_char : char;
var done : boolean;
Begin{Setup_Matrix}
 Clrscr;
 matrix.size := 0;
 while ((matrix.size < 1) or (matrix.size > 15)) do
  Begin{while}
   Write('Please enter the number of Nodes (1-15) or -1 to quit: ');
   readln(matrix.size);
   if matrix.size = -1 then
    halt;
   if ((matrix.size < 1) or (matrix.size > 15)) then
     Writeln('The number of nodes must be between 1 and 15!');
  end;{while}
  for temp := 1 to matrix.size do
   Begin{for}
    Write('Please enter the label for node ',temp,' ');
    readln(matrix.name[temp]);
    matrix.pred[temp] := 0;
    matrix.distance[temp] := 0;
    done := false;
    while ((not(done)) and (temp <> 1)) do
     begin{while}
      for temp_2 := 1 to temp-1 do
       begin{for}
        if matrix.name[temp] = matrix.name[temp_2] then
         Begin{if}
          write('Duplicate labels are not allowed enter a new label : ');
          readln(matrix.name[temp]);
          done := false;
         end{if}
        else done := true
       end{for}
     end{while}
   end{for};
  for row := 1 to matrix.size do
   Begin{for}
    for col := 1 to matrix.size do
     if matrix.a[row, col].adjacency_set <> True then
      begin
       writeln('is ',matrix.name[row],' adjacent to ',matrix.name[col],' y/n');
       temp_char := readkey;
       temp_char := upcase(temp_char);
       while ((temp_char <> 'Y') and (temp_char <> 'N')) do
        begin{while}
         writeln('Error data is invalid please enter data again (q to quit)');
         temp_char := readkey;
         temp_char := upcase(temp_char);
         if temp_char = 'Q' then
          halt;
        end{while};
       if temp_char = 'Y' then
        begin{if}
         matrix.a[row, col].info := 1;
         matrix.a[col, row].info := 1;
        end{if}
       else
        begin{else}
         matrix.a[row, col].info := 0;
         matrix.a[col, row].info := 0;
        end;{else}
       matrix.a[row, col].adjacency_set := true;
       matrix.a[col, row].adjacency_set := true
      end;{if}
   end{for}
End;{Setup_Matrix}

procedure Setup_Node(data : integer;
                     var Temp_Ptr : queuepointer);
Begin
  New(Temp_Ptr);
  Temp_Ptr^.Entry := data;
End;{Setup_Node}

Procedure Breath_First(Var Matrix: graph);
var row, col : integer;
var temp_ptr : queuepointer;
var q : queue;
Begin{Breath_First}
 row := 1;
 col := 1;
 Matrix.Visited[1] := true;
 Matrix.distance[1] := 0;
 Matrix.Pred[1] := 0;
 CreateQueue(Q);
 Setup_Node(Col, Temp_Ptr);
 Append(Temp_Ptr, Q);
 While Not(QueueEmpty(q)) do
  Begin
   Serve(Temp_Ptr, Q);
   Row := Temp_Ptr^.Entry;
   for Col := 1 to Matrix.size do
    Begin{for}
     If ((Matrix.a[row, Col].info = 1) and (Matrix.Visited[Col] <> true)) then
      Begin{if}
       Matrix.Visited[col] := true;
       Matrix.Pred[col] := row;
       Matrix.Distance[col] := Matrix.Distance[row] + 1;
       Setup_Node(Col, Temp_Ptr);{setup node creates a node to be placed into the Queue}
       Append(Temp_Ptr, Q);
      end{if}
    end;{for}
  end;{while}
End;{Breath_First}

Procedure Get_Path_Info(Mat : graph; Position : integer;var Path : String);
Var
 Temp : String;
 Next : integer;
Begin{Get_Path_Info}
 Next := Position;
 Path := Concat(' ',Mat.Name[Next]);
 Next := Mat.Pred[Next];
 While Next <> 0 do
  Begin{While}
   insert(' to', Path, 1);
   insert(Mat.Name[Next], Path, 1);
   Next := Mat.Pred[Next];
  End;{While}
  temp := Concat('The Path from ',Mat.Name[1],' to ',Mat.Name[Position],' is ');
  insert(temp, Path, 1);
End{Get_Path_Info};

PROCEDURE Print_Output(VAR Mat : graph; Var Outfile : text; To_Screen : Boolean);
{----------------------------------------------------------------------------
   Accepts:          A matrix of type graph.
   Purpose:          Display the distance from the base node to any other
                     node in the matrix.
----------------------------------------------------------------------------}
VAR
 Position, j, i, col : integer;    {row, column indices}
 Path : String;
 choice : char;
BEGIN{Print_Output}
 Writeln(Outfile,'Adjacency Matrix');
 write(Outfile,skip:5);
 FOR i := 1 to Mat.Size DO
  Begin
   write(Outfile, Mat.name[i]:4);
   write(Outfile,' ');
  end;
 Writeln(Outfile);
 FOR i := 1 TO Mat.Size DO
  Begin{for}
   write(Outfile, Mat.name[i]:4);
   FOR j := 1 TO Mat.Size DO
    Begin{for}
     write(Outfile, ' ');
     write(Outfile, Mat.a[j,i].info:4);
    end;{for}
    Writeln(Outfile);
  end;{for}
 Writeln(Outfile);
 For Position := 2 to Mat.Size do
  Begin{For}
   If Mat.Visited[Position] = false then
    Writeln(Outfile,'Their is no path from ',Mat.Name[1],' to ',Mat.Name[Position])
   else
    Begin{else}
     Writeln(Outfile,'The distance from ',Mat.Name[1],' to ',Mat.Name[Position],' is ',Mat.Distance[Position]);
     Get_Path_Info(Matrix, Position, Path);
     Writeln(Outfile, Path);
    end;{else}
   If To_Screen = true then
    Begin{if}
     writeln(Outfile);
     writeln(Outfile,'Press any key to Continue');
     choice := readkey;
    end{if};
   writeln(Outfile);
  End;{For}
End;{Print_Output}

Begin{Main}
 Setup_Matrix(Matrix);
 Breath_First(Matrix);
 clrscr;
 Writeln('Display Output to 1) Screen, 2) File, 3) Printer');
 Choice := readkey;
 case Choice of
  '2': Begin
        Readoutfile(Outfile);
        Print_Output(Matrix, Outfile, false);
        Close(Outfile);
       end;
  '3': Begin
        Print_Output(Matrix, LST, false);
       end;
 Else
  Begin
   Clrscr;
   Print_Output(Matrix, Output, true);
  end;
 end;{Case}
End{Main}.