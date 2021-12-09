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

type Point struct {
	x, y int
}

type Board5 = map[Point]int

func toPoint(s string) Point {
	var numbers []int
	for _, s := range strings.Split(s, ",") {
		i, _ := strconv.Atoi(s)
		numbers = append(numbers, i)
	}
	return Point{numbers[0], numbers[1]}
}

func makeRange(x, y int) []int {
	if x <= y {
		return _makeRange(x, y)
	} else {
		return funk.ReverseInt(_makeRange(y, x))
	}
}

func _makeRange(min, max int) []int {
	a := make([]int, max-min+1)
	for i := range a {
		a[i] = min + i
	}
	return a
}

func splitSegment(p1, p2 Point) []Point {
	minx, maxx := funk.MinInt([]int{p1.x, p2.x}), funk.MaxInt([]int{p1.x, p2.x})
	miny, maxy := funk.MinInt([]int{p1.y, p2.y}), funk.MaxInt([]int{p1.y, p2.y})

	if p1.x == p2.x {
		ys := makeRange(miny, maxy)
		return funk.Map(ys, func(i int) Point {
			return Point{p1.x, i}
		}).([]Point)
	} else if p1.y == p2.y {
		xs := makeRange(minx, maxx)
		return funk.Map(xs, func(i int) Point {
			return Point{i, p1.y}
		}).([]Point)
	} else {
		return nil
	}
}

var board = make(Board5)

func buildBoard(f io.Reader) {
	scanner := bufio.NewScanner(f)

	for scanner.Scan() {
		var p1, p2 Point
		line := scanner.Text()
		ps := strings.Split(line, " -> ")
		p1, p2 = toPoint(ps[0]), toPoint(ps[1])
		// fmt.Println(p1, p2)

		for _, p := range splitSegment(p1, p2) {
			// fmt.Println("points in between: ", p)
			board[p] += 1
		}
	}
}

func printScore() {
	f := funk.FilterInt(funk.Values(board).([]int), func(v int) bool {
		return v >= 2
	})
	fmt.Printf("Score: %d\n", len(f))
}

func main() {
	file, err := os.Open(os.Args[1])

	if err != nil {
		fmt.Println(err.Error())
	}

	buildBoard(file)

	//fmt.Println(board)
	printScore()
}
