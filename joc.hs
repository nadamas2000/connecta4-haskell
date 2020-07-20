import System.Environment
import System.Exit
import System.Random
import Data.List


type Matrix= [[Char]]
type Pos = (Int,Int)


-------------------------- Params Config --------------------------------------
usage :: IO()
usage = do putStrLn ("Uso: conecta4 n m p")
           putStrLn ("    n = Número de filas ( > 3 ) ")
           putStrLn ("    m = Número de columnas ( > 3 )")
           putStrLn ("    p = Jugador que inicia (1: Jugador, 2: CPU)")
           putStrLn ("    i = Nivel de IA (1: Random, 2: Greedy, 3: Smart)")
           exitWith (ExitFailure 1)

testNumParams :: [String] -> Bool
testNumParams args
    | length args < 4 = False
    | length args > 4 = False
    | otherwise = True
    
testRange :: Int -> Int -> Int -> Bool
testRange n minn maxn = n > minn && n < maxn

testCorrectNumbers :: [String] -> Bool
testCorrectNumbers args = (ln !! 0) > 3 && (ln !! 1) > 3 && testRange (ln !! 2) 0 3 && testRange (ln !! 3) 0 4
    where
        ln = map (read::String->Int) args

   
testArgs :: [String] -> Bool
testArgs args = testNumParams args && testCorrectNumbers args

convertArgsToParams :: [String] -> [Int]
convertArgsToParams args = [read (args !! 0) :: Int, read (args !! 1) :: Int, read (args !! 2) :: Int, read (args !! 3) :: Int]

---------------------- Pantalla -------------------------------------

intercalateSpaces :: [String] -> [String]
intercalateSpaces (n:nums)
    | length nums == 0 = [n]
    | length n > 1 = [n] ++ [" "] ++ (intercalateSpaces nums)
    | otherwise = [n] ++ [" "] ++ [" "] ++ (intercalateSpaces nums)

separateChars :: String -> String
separateChars (s:ls)
    | length ls == 0 = [s]
    | otherwise = [s] ++ [' '] ++ [' '] ++ (separateChars ls)

fileToPrint :: [Char] -> String
fileToPrint f = separateChars f

matToPrint :: [[Char]] -> [String]
matToPrint mat = map (fileToPrint) mat

numColumns :: Int -> String
numColumns m = concat $ intercalateSpaces (map (show) [1..m])

showMatrix :: [[Char]] -> IO ()
showMatrix mat = mapM_ (putStrLn) ([(numColumns (length (getFile 0 mat)))] ++ (matToPrint mat) ++ [" "])

---------------------- Juego ----------------------------------------
---------------------------------------------------------------------

---------------------- Prueba ganador -------------------------------

shiftMat :: Matrix -> Matrix
shiftMat mat
    | l == 0 = mat
    | otherwise = [['.' | x <- [1..l]] ++ (mat !! 0)] ++ shiftMat (tail mat)
    where
        l = (length mat) - 1

fourCharsEquals :: [Char] -> Bool
fourCharsEquals line
    | line !! 0 == '.' = False
    | (line !! 0 == line !! 1) && (line !! 0 == line !! 2) && (line !! 0 == line !! 3) = True
    | otherwise = False

test4InLine :: [Char] -> Bool
test4InLine line
    | (length line) - 4 < 0 = False
    | otherwise = fourCharsEquals (take 4 line) || test4InLine (tail line)

testWin :: [[Char]] -> Int
testWin mat
    | all (testUsed) (transpose mat)  == True = 2
    | (any (test4InLine) mat) || (any (test4InLine) (transpose mat)) || (any (test4InLine) (transpose $ shiftMat mat)) || (any (test4InLine) (reverse $ transpose $ shiftMat $ reverse mat)) = 1
    | otherwise = 0

---------------------- Utiles Matriz de juego ------------------------------

genMatrix :: Int -> Int -> Matrix
genMatrix n m = [['.' | x <- [1..m]] | y <- [1..n]]

getFile :: Int -> [[Char]] -> [Char]
getFile n mat = mat !! n

getColumn :: Int -> [[Char]] -> [Char]
getColumn n mat = getFile n (transpose mat)

testUsed :: [Char] -> Bool
testUsed col = (head col) /= '.'
    
testUseCol :: Matrix -> Int -> Bool
testUseCol mat c = head (getColumn c mat) == '.'

--------------------------- Movimientos -------------------------

endGame :: Int -> IO()
endGame p
    | p == 1 = putStrLn ("¡Has ganado!")
    | p == 2 = putStrLn ("Has perdido")
    | p == 3 = putStrLn ("Empate")
    
getPlayerChar :: Int -> Char
getPlayerChar p
    | p == 1 = 'X'
    | otherwise = 'O'

replaceInCol :: Int -> Char -> [Char] -> [Char]
replaceInCol n player (x:xs)
   | n == 0 = player:xs
   | otherwise = x:replaceInCol (n-1) player xs

insertCol :: [Char] -> Int -> Int -> [Char]
insertCol col pos player
    | pos == length col = replaceInCol (pos-1) (getPlayerChar player) col
    | col !! pos == '.' = insertCol col (pos + 1) player
    | otherwise = replaceInCol (pos - 1) (getPlayerChar player) col

replaceCol :: Int -> [Char] -> [[Char]] -> [[Char]]
replaceCol n col (x:xs)
   | n == 0 = col:xs
   | otherwise = x:replaceCol (n-1) col xs

setColumn :: Matrix -> Int -> Int -> Matrix
setColumn mat player col = replaceCol col (insertCol (getColumn col (transpose mat)) 0 player) mat

--------------------------- IA ---------------------------------------------

fullCols :: Matrix -> [Bool]
fullCols mat = map (testUsed) (transpose mat)

permitCols :: [Bool] -> Int -> [Int]
permitCols fc nc
    | length fc == 0 = []
    | otherwise = res ++ permitCols (tail fc) (nc + 1)
    where
        res = if (head fc)
                 then []
                 else [nc]

getSmart :: Matrix -> Int
getSmart mat = 0

getGreedy :: Matrix -> Int
getGreedy mat = 0

cpuIA :: Matrix -> Int -> Int
cpuIA mat ia
    | ia == 2 = getGreedy mat
    | otherwise = getSmart mat

randInt :: Int -> Int -> IO Int
randInt low high = do
    random <- randomIO :: IO Int
    let maxh = (abs (high - low)) + 1
    let result = low + random `mod` maxh
    return result
    
nextWin :: Matrix -> [Int] -> Int
nextWin mat pcol
    | length pcol == 0 = -1
    | testWin (transpose (setColumn (transpose mat) 2 c)) == 1 = c
    | otherwise = nextWin mat (tail pcol)
    where
        c = head pcol

getFirstBestCol :: [Int] -> Int -> Int -> Int
getFirstBestCol pathTreeValues bestColValue n
    | n >= length pathTreeValues = -1
    | bestColValue == (head pathTreeValues) = n
    | otherwise = getFirstBestCol (tail pathTreeValues) bestColValue (n + 1)

checkPath :: [[Char]] -> Int
checkPath mat
    | all (testUsed) (transpose mat)  == True = 1
    | (any (test4InLine) mat) || (any (test4InLine) (transpose mat)) || (any (test4InLine) (transpose $ shiftMat mat)) || (any (test4InLine) (reverse $ transpose $ shiftMat $ reverse mat)) = 3
    | otherwise = 0    

checkMov :: Matrix -> Int -> Int
checkMov mat col
    | testUsed (getColumn col mat) = 0
    | otherwise = checkPath (transpose (setColumn (transpose mat) 2 col))

mergeResultPaths :: [Int] -> [Int] -> [Int]
mergeResultPaths first second
    | length first == 0 = []
    | otherwise = [(head first) + (head second)] ++ mergeResultPaths (tail first) (tail second)

mergeDeepValues :: Int -> Int -> [Int] -> [Matrix] -> [Int]
mergeDeepValues deep maxdeep values matList
    | length matList == 1 = thisMat
    | otherwise = mergeResultPaths thisMat (mergeDeepValues deep maxdeep values (tail matList))
    where
        thisMat = winpath (deep + 1) maxdeep values (head matList)

pathList :: Matrix -> [Int] -> [Matrix]
pathList mat pcols
    | length pcols == 0 = []
    | otherwise = [transpose (setColumn (transpose mat) 2 (head pcols))] ++ (pathList mat (tail pcols))
    
winpath :: Int -> Int -> [Int] -> Matrix -> [Int]
winpath deep maxdeep values mat
    | testWin mat /= 0 = values
    | deep == maxdeep = mergeResultPaths values pathsValues
    | otherwise = mergeResultPaths values mergedValues
    where
        pcols = permitCols (fullCols mat) 0
        pathsValues = map (checkMov mat) [1..(length mat)]
        nextDeepValues = mergeDeepValues deep maxdeep values nextMatPaths
        nextMatPaths = pathList mat pcols
        mergedValues = mergeResultPaths pathsValues nextDeepValues

bestCol :: Matrix -> Int
bestCol mat = getFirstBestCol pathTreeValues bestColValue 0
    where pathTreeValues = winpath 0 10 initValues mat
          bestColValue = maximum pathTreeValues
          initValues = [0 | x <- [1..(length mat)]]


---------------------- Turnos -----------------------------------------------

cpuTurn :: Matrix -> Int -> IO()
cpuTurn mat ia = do    
    let pcols = permitCols (fullCols mat) 0
    rand <- randInt 0 ((length pcols) - 1)    
    let c = pcols !! rand
    if (ia == 1)
       then do
           putStrLn (" CPU escoge la columna " ++ (show (c + 1)))    
           let newMat = transpose (setColumn (transpose mat) 2 c)
           showMatrix newMat
           let result = testWin newMat
           if (result == 2)
              then endGame 3
              else do
                  if (result == 1)
                     then endGame 2
                     else userTurn newMat ia                                
       else do           
           if (ia == 2)
              then do
                  let nw = nextWin mat pcols
                  if (nw >= 0)
                     then do
                         putStrLn (" CPU escoge la columna " ++ (show (nw + 1)))    
                         let newMat = transpose (setColumn (transpose mat) 2 (nw))          
                         showMatrix newMat        
                         endGame 2
                     else do 
                         putStrLn (" CPU escoge la columna " ++ (show (c + 1)))    
                         let newMat = transpose (setColumn (transpose mat) 2 c)
                         showMatrix newMat
                         let result = testWin newMat
                         if (result == 2)
                            then endGame 3
                            else do
                                if (result == 1)
                                   then endGame 2
                                   else userTurn newMat ia
              else do
                  let bc = bestCol mat
                  print bc
                  if (bc >= 0)
                     then do 
                         let newMat = transpose (setColumn (transpose mat) 2 (bc))          
                         showMatrix newMat        
                         endGame 2
                     else do 
                         let newMat = transpose (setColumn (transpose mat) 2 c)
                         showMatrix newMat
                         let result = testWin newMat
                         if (result == 2)
                            then endGame 3
                            else do
                                if (result == 1)
                                   then endGame 2
                                   else userTurn newMat ia

    
userTurn :: Matrix -> Int -> IO()
userTurn mat ia = do
    putStrLn (" Escoge una columna: ")
    line <- getLine
    let c = (read line :: Int) - 1    
    if (testUseCol mat c)
       then do
           let newMat = transpose (setColumn (transpose mat) 1 c)
           showMatrix newMat
           let result = testWin newMat
           if (result == 2)
              then endGame 3
              else do
                  if (result == 1)
                     then endGame 1
                     else do                        
                         cpuTurn newMat ia
       else userTurn mat ia

---------------------  Inicio -----------------------------------

jugar :: [Int] -> IO()
jugar params = do 
    if (params !! 3 == 1 )
       then do putStrLn ("El nivel de IA es Random ")
       else do
           if (params !! 3 == 2)
              then do putStrLn ("El nivel de IA es Greedy") 
              else do putStrLn ("El nivel de IA es Smart") 
    let n = params !! 0
    let m = params !! 1     
    showMatrix mat
    if ((params !! 2) == 2)
       then cpuTurn mat (params !! 3)
       else userTurn mat (params !! 3)
    where        
        mat = genMatrix (params !! 0) (params !! 1)
       
main :: IO ()
main = do args <- getArgs
          putStrLn ("Comienza el juego:")
          putStrLn ("     - Tu símbolo es X y la CPU tiene el símbolo O.")
          putStrLn ("     - Los espacios vacíos se representan por un punto.")
          putStrLn ("     - Las columnas están numeradas para facilitar el seguimiento.")
          putStrLn ("     ")                    
          if testArgs args
             then jugar (convertArgsToParams args)
             else usage
