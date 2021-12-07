package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"regexp"
	"strconv"
	"strings"
)

type Cell struct {
	value  int
	marked bool
}

type Board = [][]Cell

var re = regexp.MustCompile("[0-9]+")

func BuildBoards(f io.Reader) ([]int, []Board) {
	scanner := bufio.NewScanner(f)

	// first line for numbers
	scanner.Scan()
	var draws []int
	for _, s := range strings.Split(scanner.Text(), ",") {
		i, _ := strconv.Atoi(s)
		draws = append(draws, i)
	}

	// empty line
	scanner.Scan()

	var boards []Board
	var currBoard Board
	for scanner.Scan() {
		line := scanner.Text()
		if len(line) > 1 {
			row := make([]Cell, 0)
			for _, s := range re.FindAllString(line, -1) {
				i, _ := strconv.Atoi(s)
				row = append(row, Cell{i, false})
			}
			if currBoard == nil {
				currBoard = make(Board, 0)
			}
			currBoard = append(currBoard, row)
		} else {
			boards = append(boards, currBoard)
			currBoard = nil
		}
	}
	boards = append(boards, currBoard)
	return draws, boards
}

func PrintScore(board Board, num int) {
	var sum = 0
	for x := 0; x < len(board); x++ {
		for y := 0; y < len(board); y++ {
			if !board[x][y].marked {
				sum += board[x][y].value
			}
		}
	}
	fmt.Printf("Score: %d\n", sum*num)
}

func CheckBingo(board Board, x, y int) bool {
	// check if bingo
	// row first
	var allMarked = true
	for i := 0; i < len(board); i++ {
		if !board[x][i].marked {
			allMarked = false
			break
		}
	}

	if allMarked {
		return true
	}

	// column
	allMarked = true
	for i := 0; i < len(board); i++ {
		if !board[i][y].marked {
			allMarked = false
			break
		}
	}
	if allMarked {
		return true
	}
	return false
}

func main() {
	file, err := os.Open(os.Args[1])

	if err != nil {
		fmt.Println(err.Error())
	}

	draws, boards := BuildBoards(file)

	fmt.Printf("%d boards found\n", len(boards))
	fmt.Printf("sizeof board %d x %d\n", len(boards[0]), len(boards[0][0]))

	winBoards := map[int]bool{}
	// play now
	for _, num := range draws {
		// mark all boards for num
		for bi, board := range boards {
			for x := 0; x < len(board); x++ {
				for y := 0; y < len(board); y++ {
					if board[x][y].value == num {
						board[x][y].marked = true

						if !winBoards[bi] && CheckBingo(board, x, y) {
							fmt.Printf("Bingo, board: %d, column: %d\n", bi+1, y+1)
							winBoards[bi] = true
							if len(winBoards) == len(boards) {
								PrintScore(board, num)
								return
							}
						}
					}
				}
			}
		}
	}
}
