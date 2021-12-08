package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"regexp"
	"strconv"
	"strings"

	"github.com/thoas/go-funk"
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

	// read all non-empty lines
	lines := []string{}
	for scanner.Scan() {
		line := scanner.Text()
		if line != "" {
			lines = append(lines, line)
		}
	}

	// spit lines into boards
	boards := funk.Map(funk.Chunk(lines, 5), func(lines []string) Board {
		return funk.Map(lines, func(line string) []Cell {
			return funk.Map(re.FindAllString(line, -1), func(s string) Cell {
				i, _ := strconv.Atoi(s)
				return Cell{i, false}
			}).([]Cell)
		}).(Board)
	}).([]Board)

	return draws, boards
}

// PrintScore calculates and prints the score of board
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

// CheckBingo check if bingo
func CheckBingo(board Board, x, y int) bool {
	// row first
	if r := funk.Find(board[x], func(c Cell) bool {
		return !c.marked
	}); r == nil {
		return true
	}

	// column
	if r := funk.Find(board, func(row []Cell) bool {
		return !row[y].marked
	}); r == nil {
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

	// play now
	for _, num := range draws {
		// mark all boards for num
		for bi, board := range boards {
			for x := 0; x < len(board); x++ {
				for y := 0; y < len(board); y++ {
					if board[x][y].value == num {
						board[x][y].marked = true

						if CheckBingo(board, x, y) {
							fmt.Printf("Bingo, board: %d, column: %d\n", bi+1, y+1)
							PrintScore(board, num)
							return
						}
					}
				}
			}
		}
	}
}
