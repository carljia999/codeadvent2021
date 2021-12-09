package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"

	"github.com/thoas/go-funk"
)

type State = map[int]int

func buildBoard(f io.Reader) State {
	scanner := bufio.NewScanner(f)
	board := make(State)
	for scanner.Scan() {
		for _, s := range strings.Split(scanner.Text(), ",") {
			i, _ := strconv.Atoi(s)
			board[i] += 1
		}
	}
	return board
}

func printScore(s State) {
	count := funk.SumInt(funk.Values(s).([]int))

	/*ds := []int{}
	for d, c := range s {
		for i := 0; i < c; i++ {
			ds = append(ds, d)
		}
	}
	fmt.Printf("Fish: %v\n", ds)*/
	fmt.Printf("Score: %d\n", count)
}

func simulate(days int, s State) State {
	for days > 0 {
		ns := make(State)
		for d, c := range s {
			if d == 0 {
				ns[8] = c
				d = 6
			} else {
				d--
			}
			ns[d] += c
		}
		s = ns
		days--
	}
	return s
}

func main() {
	file, err := os.Open(os.Args[1])

	if err != nil {
		fmt.Println(err.Error())
	}

	board := buildBoard(file)

	board = simulate(256, board)

	printScore(board)
}
